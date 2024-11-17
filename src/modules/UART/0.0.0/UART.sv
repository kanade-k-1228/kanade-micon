module simpleuart #(
    parameter integer DEFAULT_DIV = 1,
    parameter integer RX_TIMEOUT  = 1000
) (
    input clk,
    input resetn,

    output ser_tx,
    input  ser_rx,

    input  [ 3:0] reg_div_we,
    input  [31:0] reg_div_di,
    output [31:0] reg_div_do,

    input         reg_dat_we,
    input         reg_dat_re,
    input  [31:0] reg_dat_di,
    output [31:0] reg_dat_do,
    output        reg_dat_wait
);

  always @(posedge clk) begin
    if (!resetn) begin
      cfg_divider <= DEFAULT_DIV;
    end else begin
      if (reg_div_we[0]) cfg_divider[7:0] <= reg_div_di[7:0];
      if (reg_div_we[1]) cfg_divider[15:8] <= reg_div_di[15:8];
      if (reg_div_we[2]) cfg_divider[23:16] <= reg_div_di[23:16];
      if (reg_div_we[3]) cfg_divider[31:24] <= reg_div_di[31:24];
    end
  end

  reg [3:0] recv_state;
  reg [31:0] recv_divcnt;
  reg [7:0] recv_pattern;
  reg [7:0] recv_buf_data;
  reg recv_buf_valid;

  always @(posedge clk) begin
    if (!resetn) begin
      recv_state <= 0;
      recv_divcnt <= 0;
      recv_pattern <= 0;
      recv_buf_data <= 0;
      recv_buf_valid <= 0;
    end else begin
      recv_divcnt <= recv_divcnt + 1;
      if (reg_dat_re) recv_buf_valid <= 0;
      case (recv_state)
        0: begin
          if (!ser_rx) recv_state <= 1;
          recv_divcnt <= 0;
        end
        1: begin
          if (2 * recv_divcnt > cfg_divider) begin
            recv_state  <= 2;
            recv_divcnt <= 0;
          end
        end
        10: begin
          if (recv_divcnt > cfg_divider) begin
            recv_buf_data <= recv_pattern;
            recv_buf_valid <= 1;
            recv_state <= 0;
          end
        end
        default: begin
          if (recv_divcnt > cfg_divider) begin
            recv_pattern <= {ser_rx, recv_pattern[7:1]};
            recv_state   <= recv_state + 1;
            recv_divcnt  <= 0;
          end
        end
      endcase
    end
  end

  assign ser_tx = send_pattern[0];

  reg [9:0] send_pattern;
  reg [3:0] send_bitcnt;
  reg [31:0] send_divcnt;
  reg send_dummy;

  always @(posedge clk) begin
    if (reg_div_we) send_dummy <= 1;
    send_divcnt <= send_divcnt + 1;
    if (!resetn) begin
      send_pattern <= ~0;
      send_bitcnt  <= 0;
      send_divcnt  <= 0;
      send_dummy   <= 1;
    end else begin
      if (send_dummy && !send_bitcnt) begin
        send_pattern <= ~0;
        send_bitcnt  <= 15;
        send_divcnt  <= 0;
        send_dummy   <= 0;
      end else if (reg_dat_we && !send_bitcnt) begin
        send_pattern <= {1'b1, reg_dat_di[7:0], 1'b0};
        send_bitcnt  <= 10;
        send_divcnt  <= 0;
      end else if (send_divcnt > cfg_divider && send_bitcnt) begin
        send_pattern <= {1'b1, send_pattern[9:1]};
        send_bitcnt  <= send_bitcnt - 1;
        send_divcnt  <= 0;
      end
    end
  end

  reg [31:0] cfg_divider;

  assign reg_div_do   = cfg_divider;

  assign reg_dat_wait = reg_dat_we && (send_bitcnt || send_dummy);
  assign reg_dat_do   = recv_buf_valid ? recv_buf_data : ~0;

endmodule

module UART (
    input wire clk,
    input wire resetn,

    input wire valid,
    output wire ready,
    input wire [3:0] wstrb,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output wire [31:0] rdata,

    output tx,
    input  rx
);

  wire div_valid = valid && addr[2] == 1'b0;
  wire div_ready = div_valid;
  wire [31:0] div_rdata;

  wire reg_dat_wait;
  wire dat_valid = valid && addr[2] == 1'b1;
  wire dat_ready = dat_valid && !reg_dat_wait;
  wire dat_wstrb = dat_valid ? wstrb[0] : 1'b0;
  wire [31:0] dat_rdata;

  assign ready = |{div_ready, dat_ready};
  assign rdata = div_ready ? div_rdata : dat_ready ? dat_rdata : 32'h0000_0000;

  simpleuart uart (
      .clk   (clk),
      .resetn(resetn),

      .reg_div_we(div_valid ? wstrb : 4'b0),
      .reg_div_di(wdata),
      .reg_div_do(div_rdata),

      .reg_dat_we  (dat_wstrb),
      .reg_dat_re  (dat_valid && !dat_wstrb),
      .reg_dat_di  (wdata),
      .reg_dat_do  (dat_rdata),
      .reg_dat_wait(reg_dat_wait),

      .ser_tx(tx),
      .ser_rx(rx)
  );

endmodule
