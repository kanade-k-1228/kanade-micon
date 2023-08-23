/*
 *  PicoSoC - A simple example SoC using PicoRV32
 *
 *  Copyright (C) 2017  Claire Xenia Wolf <claire@yosyshq.com>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

`timescale 1 ns / 1 ps

module testbench;

  /////////////////////////////////////
  // Simulation

  parameter CYCLE = 30_0000;
  initial begin
    $dumpfile(".build/simulation.vcd");
    $dumpvars(0, testbench);
    repeat (CYCLE) @(posedge clk);
    $finish;
  end

  /////////////////////////////////////
  // Clock

  reg clk = 0;
  always #5 clk = ~clk;

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

  hardware hardware (
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

  wire flash_csb, flash_clk, flash_io0, flash_io1, flash_io2, flash_io3;
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
  wire serial_print;
  wire serial_input;

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
