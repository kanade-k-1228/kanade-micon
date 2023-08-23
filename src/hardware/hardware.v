module hardware (
    input  fpga_clk,
    inout  fpga_flash_csb,
    inout  fpga_flash_clk,
    inout  fpga_flash_io0,
    inout  fpga_flash_io1,
    inout  fpga_flash_io2,
    inout  fpga_flash_io3,
    /* iopin */
    inout  fpga_user_led,
    input  fpga_pin11,
    input  fpga_pin2,
    output fpga_pin1,
    output fpga_pin24,
    output fpga_pin23,
    output fpga_pin22,
    output fpga_pin21
    /* end */
);

  /* iopin_assign */
  assign fpga_pin1  = serial_tx;
  assign fpga_pin24 = dac_cs;
  assign fpga_pin23 = dac_scl;
  assign fpga_pin22 = dac_sdi;
  assign fpga_pin21 = dac_ldac;
  /* end */

  ///////////////////////////////////
  // Wire Deffinitions

  wire clk = fpga_clk;
  wire resetn;

  ///////////////////////////////////
  // Parameters

  parameter integer MEM_WORDS = 2048;
  parameter [31:0] STACKADDR = (4 * MEM_WORDS);  // end of memory
  parameter [31:0] PROGADDR_RESET = 32'h0005_0000;  // 1 MB into flash
  parameter [31:0] PROGADDR_IRQ = 32'h0005_0010;  // 1 MB into flash

  /* parameters */
  /* end */

  ///////////////////////////////////
  // Interrupts Request

  reg [31:0] irq;
  always @* begin
    if (!resetn) irq <= 0;
    else begin
      irq = 0;
      /* irq */
      irq[5] = fpga_pin11;
      /* end */
    end
  end

  ///////////////////////////////////
  // CPU

  picorv32 #(
      .STACKADDR(STACKADDR),
      .PROGADDR_RESET(PROGADDR_RESET),
      .PROGADDR_IRQ(PROGADDR_IRQ),
      .BARREL_SHIFTER(1),
      .COMPRESSED_ISA(1),
      .ENABLE_MUL(1),
      .ENABLE_DIV(1),
      .ENABLE_IRQ(1),
      .ENABLE_IRQ_QREGS(1)
  ) cpu (
      .clk      (clk),
      .resetn   (resetn),
      .mem_valid(mem_valid),
      .mem_ready(mem_ready),
      .mem_addr (mem_addr),
      .mem_wdata(mem_wdata),
      .mem_wstrb(mem_wstrb),
      .mem_rdata(mem_rdata),
      .irq      (irq)
  );

  ///////////////////////////////////
  // Memory map interface

  wire mem_valid;
  wire mem_ready;
  wire [3:0] mem_wstrb;
  wire [31:0] mem_addr;
  wire [31:0] mem_wdata;
  wire [31:0] mem_rdata;
  assign mem_ready = |{ram_ready, rom_ready, rom_cfg_ready,  /* mem_ready */
      serial_ready,gpio_ready,square1_ready,square2_ready,square3_ready,sawtooth_ready,triangle_ready,mixier_ready,sampling_ready,dac_ready
      /* end */};
  assign mem_rdata = ram_ready ? ram_rdata : rom_ready ? rom_rdata : rom_cfg_ready ? rom_cfg_rdata /* mem_rdata */
      : serial_ready ? serial_rdata : gpio_ready ? gpio_rdata : square1_ready ? square1_rdata : square2_ready ? square2_rdata : square3_ready ? square3_rdata : sawtooth_ready ? sawtooth_rdata : triangle_ready ? triangle_rdata : mixier_ready ? mixier_rdata : sampling_ready ? sampling_rdata : dac_ready ? dac_rdata
      /* end */ : 32'b0;

  ///////////////////////////////////
  // Modules

  por por (
      .clk(clk),
      .resetn(resetn)
  );

  ram #(
      .WORDS(MEM_WORDS)
  ) ram (
      .clk(clk),
      .resetn(resetn),
      .valid(ram_valid),
      .ready(ram_ready),
      .wstrb(ram_valid ? mem_wstrb : 4'b0),
      .addr(mem_addr),
      .wdata(mem_wdata),
      .rdata(ram_rdata)
  );
  wire ram_sel = mem_addr[31:14] == 19'h0;
  wire ram_valid = mem_valid && ram_sel;
  wire ram_ready;
  wire [31:0] ram_rdata;

  spirom rom (
      .clk(clk),
      .resetn(resetn),
      .valid(rom_valid),
      .ready(rom_ready),
      .wstrb(rom_valid ? mem_wstrb : 4'b0),
      .addr (mem_addr),
      .wdata(mem_wdata),
      .rdata(rom_rdata),
      .cfg_valid(rom_cfg_valid),
      .cfg_ready(rom_cfg_ready),
      .cfg_wstrb(rom_cfg_valid ? mem_wstrb : 4'b0),
      .cfg_addr (mem_addr),
      .cfg_wdata(mem_wdata),
      .cfg_rdata(rom_cfg_rdata),
      .flash_io0_iosel(flash_io0_iosel),
      .flash_io0_in   (flash_io0_in),
      .flash_io0_out  (flash_io0_out),
      .flash_io1_iosel(flash_io1_iosel),
      .flash_io1_in   (flash_io1_in),
      .flash_io1_out  (flash_io1_out),
      .flash_io2_iosel(flash_io2_iosel),
      .flash_io2_in   (flash_io2_in),
      .flash_io2_out  (flash_io2_out),
      .flash_io3_iosel(flash_io3_iosel),
      .flash_io3_in   (flash_io3_in),
      .flash_io3_out  (flash_io3_out),
      .flash_csb(fpga_flash_csb),
      .flash_clk(fpga_flash_clk)
  );
  wire rom_sel = (mem_addr[31:20] == 12'h000) && (4'h5 <= mem_addr[19:16]);
  wire rom_valid = mem_valid && rom_sel;
  wire rom_ready;
  wire [31:0] rom_rdata;
  wire rom_cfg_sel = mem_addr[31:24] == 8'h02;
  wire rom_cfg_valid = mem_valid && rom_cfg_sel;
  wire rom_cfg_ready;
  wire [31:0] rom_cfg_rdata;
  wire flash_io0_iosel;
  wire flash_io0_in;
  wire flash_io0_out;
  wire flash_io1_iosel;
  wire flash_io1_in;
  wire flash_io1_out;
  wire flash_io2_iosel;
  wire flash_io2_in;
  wire flash_io2_out;
  wire flash_io3_iosel;
  wire flash_io3_in;
  wire flash_io3_out;
  tristate flash_io0_iobuf (
      .pin  (fpga_flash_io0),
      .iosel(flash_io0_iosel),
      .in   (flash_io0_in),
      .out  (flash_io0_out)
  );
  tristate flash_io1_iobuf (
      .pin  (fpga_flash_io1),
      .iosel(flash_io1_iosel),
      .in   (flash_io1_in),
      .out  (flash_io1_out)
  );
  tristate flash_io2_iobuf (
      .pin  (fpga_flash_io2),
      .iosel(flash_io2_iosel),
      .in   (flash_io2_in),
      .out  (flash_io2_out)
  );
  tristate flash_io3_iobuf (
      .pin  (fpga_flash_io3),
      .iosel(flash_io3_iosel),
      .in   (flash_io3_in),
      .out  (flash_io3_out)
  );

  /* instances */
  uart serial (
      .clk(clk),
      .resetn(resetn),
      .valid(serial_valid),
      .ready(serial_ready),
      .wstrb(serial_valid ? mem_wstrb : 4'b0),
      .addr(mem_addr),
      .wdata(mem_wdata),
      .rdata(serial_rdata),
      .rx(fpga_pin2),
      .tx(serial_tx)
  );
  wire serial_sel = mem_addr[31:24] == 8'h03;
  wire serial_valid = mem_valid && serial_sel;
  wire serial_ready;
  wire [31:0] serial_rdata;
  wire serial_tx;

  gpio gpio (
      .clk(clk),
      .resetn(resetn),
      .valid(gpio_valid),
      .ready(gpio_ready),
      .wstrb(gpio_valid ? mem_wstrb : 4'b0),
      .addr (mem_addr),
      .wdata(mem_wdata),
      .rdata(gpio_rdata),
      .io_iosel(gpio_io_iosel),
      .io_in   (gpio_io_in),
      .io_out  (gpio_io_out)
  );
  wire gpio_sel = mem_addr[31:24] == 8'h04;
  wire gpio_valid = mem_valid && gpio_sel;
  wire gpio_ready;
  wire [31:0] gpio_rdata;
  wire gpio_io_iosel;
  wire gpio_io_in;
  wire gpio_io_out;
  tristate gpio_io_iobuf (
      .pin  (fpga_user_led),
      .iosel(gpio_io_iosel),
      .in   (gpio_io_in),
      .out  (gpio_io_out)
  );

  osc_square square1 (
      .clk(clk),
      .resetn(resetn),
      .valid(square1_valid),
      .ready(square1_ready),
      .wstrb(square1_valid ? mem_wstrb : 4'b0),
      .addr(mem_addr),
      .wdata(mem_wdata),
      .rdata(square1_rdata),
      .out(square1_out)
  );
  wire square1_sel = mem_addr[31:24] == 8'h05;
  wire square1_valid = mem_valid && square1_sel;
  wire square1_ready;
  wire [31:0] square1_rdata;
  wire [7:0] square1_out;

  osc_square square2 (
      .clk(clk),
      .resetn(resetn),
      .valid(square2_valid),
      .ready(square2_ready),
      .wstrb(square2_valid ? mem_wstrb : 4'b0),
      .addr(mem_addr),
      .wdata(mem_wdata),
      .rdata(square2_rdata),
      .out(square2_out)
  );
  wire square2_sel = mem_addr[31:24] == 8'h06;
  wire square2_valid = mem_valid && square2_sel;
  wire square2_ready;
  wire [31:0] square2_rdata;
  wire [7:0] square2_out;

  osc_square square3 (
      .clk(clk),
      .resetn(resetn),
      .valid(square3_valid),
      .ready(square3_ready),
      .wstrb(square3_valid ? mem_wstrb : 4'b0),
      .addr(mem_addr),
      .wdata(mem_wdata),
      .rdata(square3_rdata),
      .out(square3_out)
  );
  wire square3_sel = mem_addr[31:24] == 8'h07;
  wire square3_valid = mem_valid && square3_sel;
  wire square3_ready;
  wire [31:0] square3_rdata;
  wire [7:0] square3_out;

  osc_sawtooth sawtooth (
      .clk(clk),
      .resetn(resetn),
      .valid(sawtooth_valid),
      .ready(sawtooth_ready),
      .wstrb(sawtooth_valid ? mem_wstrb : 4'b0),
      .addr(mem_addr),
      .wdata(mem_wdata),
      .rdata(sawtooth_rdata),
      .out(sawtooth_out)
  );
  wire sawtooth_sel = mem_addr[31:24] == 8'h08;
  wire sawtooth_valid = mem_valid && sawtooth_sel;
  wire sawtooth_ready;
  wire [31:0] sawtooth_rdata;
  wire [7:0] sawtooth_out;

  osc_triangle triangle (
      .clk(clk),
      .resetn(resetn),
      .valid(triangle_valid),
      .ready(triangle_ready),
      .wstrb(triangle_valid ? mem_wstrb : 4'b0),
      .addr(mem_addr),
      .wdata(mem_wdata),
      .rdata(triangle_rdata),
      .out(triangle_out)
  );
  wire triangle_sel = mem_addr[31:24] == 8'h09;
  wire triangle_valid = mem_valid && triangle_sel;
  wire triangle_ready;
  wire [31:0] triangle_rdata;
  wire [7:0] triangle_out;

  mixier mixier (
      .clk(clk),
      .resetn(resetn),
      .valid(mixier_valid),
      .ready(mixier_ready),
      .wstrb(mixier_valid ? mem_wstrb : 4'b0),
      .addr(mem_addr),
      .wdata(mem_wdata),
      .rdata(mixier_rdata),
      .ch0(square1_out),
      .ch1(square2_out),
      .ch2(square3_out),
      .ch3(sawtooth_out),
      .ch4(triangle_out),
      .out(mixier_out)
  );
  wire mixier_sel = mem_addr[31:24] == 8'h0A;
  wire mixier_valid = mem_valid && mixier_sel;
  wire mixier_ready;
  wire [31:0] mixier_rdata;
  wire [11:0] mixier_out;

  counter sampling (
      .clk(clk),
      .resetn(resetn),
      .valid(sampling_valid),
      .ready(sampling_ready),
      .wstrb(sampling_valid ? mem_wstrb : 4'b0),
      .addr(mem_addr),
      .wdata(mem_wdata),
      .rdata(sampling_rdata),
      .overflow(sampling_overflow)
  );
  wire sampling_sel = mem_addr[31:24] == 8'h0B;
  wire sampling_valid = mem_valid && sampling_sel;
  wire sampling_ready;
  wire [31:0] sampling_rdata;
  wire sampling_overflow;

  spidac dac (
      .clk(clk),
      .resetn(resetn),
      .valid(dac_valid),
      .ready(dac_ready),
      .wstrb(dac_valid ? mem_wstrb : 4'b0),
      .addr(mem_addr),
      .wdata(mem_wdata),
      .rdata(dac_rdata),
      .analog(mixier_out),
      .sample(sampling_overflow),
      .cs(dac_cs),
      .scl(dac_scl),
      .sdi(dac_sdi),
      .ldac(dac_ldac)
  );
  wire dac_sel = mem_addr[31:24] == 8'h0C;
  wire dac_valid = mem_valid && dac_sel;
  wire dac_ready;
  wire [31:0] dac_rdata;
  wire dac_cs;
  wire dac_scl;
  wire dac_sdi;
  wire dac_ldac;
  /* end */

endmodule
