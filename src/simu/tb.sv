`timescale 1 ns / 1 ps

module tb;

  /////////////////////////////////////
  // Clock

  reg clk = 0;
  always #5 clk = ~clk;

  /////////////////////////////////////
  // Simulation

  parameter CYCLE = 30_0000;
  initial begin
    $dumpfile(".build/simulation.vcd");
    $dumpvars(0, tb);
    repeat (CYCLE) @(posedge clk);
    $finish;
  end

  /////////////////////////////////////
  // Async events

  integer cycle_cnt = 0;
  reg irq_5 = 0;

  always @(posedge clk) begin
    cycle_cnt <= cycle_cnt + 1;
    irq_5 <= 0;

    case (cycle_cnt)
      10_0000: irq_5 <= 1;
    endcase

  end

  /////////////////////////////////////
  // Main Module

  wire flash_csb, flash_clk, flash_io0, flash_io1, flash_io2, flash_io3;
  wire serial_print, serial_input;

  top dut (
      .fpga_clk  (clk),
      .fpga_pin11(irq_5),

      .fpga_pin1(serial_print),
      .fpga_pin2(serial_input),

      .fpga_flash_csb(flash_csb),
      .fpga_flash_clk(flash_clk),
      .fpga_flash_io0(flash_io0),
      .fpga_flash_io1(flash_io1),
      .fpga_flash_io2(flash_io2),
      .fpga_flash_io3(flash_io3)
  );

  /////////////////////////////////////
  // SPI Flash

  spiflash spiflash (
      .csb(flash_csb),
      .clk(flash_clk),
      .io0(flash_io0),
      .io1(flash_io1),
      .io2(flash_io2),
      .io3(flash_io3)
  );

  /////////////////////////////////////
  // UART Serial
  //
  // __       ______ ______   ______ _____
  //   |__S__/__D0__X__D1__XXX__D7__/  S  
  //    Start                        Stop   
  //

  parameter CLKDIV = 12;

  reg [7:0] serial_receive_buffer = 0;
  always begin
    @(negedge serial_print);  // begin receiving
    repeat (CLKDIV) @(posedge clk);  // start bit
    repeat (8) begin
      repeat (CLKDIV) @(posedge clk);  // data bit
      serial_receive_buffer = {serial_print, serial_receive_buffer[7:1]};
    end
    repeat (CLKDIV) @(posedge clk);  // stop bit
    // print
    if (serial_receive_buffer < 32 || serial_receive_buffer >= 127)
      $display("Serial data: %d", serial_receive_buffer);
    else $display("Serial data: '%c'", serial_receive_buffer);
  end

  /////////////////////////////////////

endmodule
