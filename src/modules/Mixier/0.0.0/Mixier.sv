//////////////////////////////////////////////////////////////////
// Mixier ////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//        : _   _  :_   _   _   _   _   _   _  :_   _  :_   _   //
// clk    :  |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_ //
//        :        :                           :       :        //
// state  :  out   | add                       | out   | add    //
// ch_cnt :        | 0         |...| NCH-1     |       :        //
// cnt    :  0 | 1 | 0 | 1 | 2 |...| 0 | 1 | 2 |       :        //
//        :        :           :               :       :        //
//       [I]      [N]         [N]             [O] [R] [S]       //
//////////////////////////////////////////////////////////////////

// 入力: 8bit x 4ch : 0000_0000 ~ 1111_1111
// 音量: 6step : 0~5
// 出力: 12bit

// 内部加算器: 16bit
// 最大値: 1111_1111 x 4 x 2^5 = 0111_1111_1000_0000

// Mixier Scalable
// 順番に加算する
module Mixier #(
    parameter N_CH = 4,  // チャンネル数 (0~8)
    parameter CALC_CNT = 4  // 計算に必要な待ち時間 (0~15)
) (
    input wire clk,
    input wire resetn,

    input wire valid,
    output reg ready,
    input wire [3:0] wstrb,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output reg [31:0] rdata,

    input wire [7:0] ch0,
    input wire [7:0] ch1,
    input wire [7:0] ch2,
    input wire [7:0] ch3,

    output reg [11:0] out
);

  wire [7:0] ch[N_CH];
  assign ch[0] = ch0;
  assign ch[1] = ch1;
  assign ch[2] = ch2;
  assign ch[3] = ch3;

  reg [3:0] vol[8];
  integer i;
  always @(posedge clk) begin
    if (!resetn) begin
      for (i = 0; i < 4; i = i + 1) begin
        vol[i] <= 4'b0;
      end
    end else begin
      ready <= valid;
      rdata <= vol[addr[4:2]];
      if (wstrb[0]) vol[addr[4:2]] <= wdata[3:0];
    end
  end

  reg state;
  parameter STATE_ADD = 1'b1;
  parameter STATE_OUT = 1'b0;
  reg [3:0] ch_cnt;
  reg [3:0] cnt;
  reg [15:0] tmp;
  wire [15:0] calc = (ch[ch_cnt] << vol[ch_cnt]) + ((1000000 - (1 << vol[ch_cnt])) << 7) + tmp;

  always @(posedge clk) begin
    if (!resetn) begin  // [I] Initialize
      state <= STATE_ADD;
      ch_cnt <= 0;
      cnt <= 0;
      tmp <= 0;
      out <= 0;
    end else begin
      case (state)
        STATE_ADD: begin
          case (cnt == CALC_CNT - 1)
            0: begin
              cnt <= cnt + 1;
            end
            1: begin  // [N] Next Count
              tmp <= calc;
              case (ch_cnt == N_CH - 1)
                0: begin
                  ch_cnt <= ch_cnt + 1;
                  cnt <= 0;
                end
                1: begin  // [O] Output result
                  state <= STATE_OUT;
                end
              endcase
            end
          endcase
        end
        STATE_OUT: begin
          out <= tmp[15:4];
          state <= STATE_ADD;
          ch_cnt <= 0;
          cnt <= 0;
          tmp <= 0;
        end
      endcase
    end
  end

endmodule

// Mixier Parallel
// module Mixier #(
//     parameter N_CH = 4  // チャンネル数
// ) (
//     input wire clk,
//     input wire resetn,

//     input wire valid,
//     output reg ready,
//     input wire [3:0] wstrb,
//     input wire [31:0] addr,
//     input wire [31:0] wdata,
//     output reg [31:0] rdata,

//     input wire [7:0] ch0,
//     input wire [7:0] ch1,
//     input wire [7:0] ch2,
//     input wire [7:0] ch3,

//     output reg [11:0] out
// );

//   wire [7:0] ch[N_CH];
//   assign ch[0] = ch0;
//   assign ch[1] = ch1;
//   assign ch[2] = ch2;
//   assign ch[3] = ch3;

//   // Mixier Registors
//   reg [2:0] vol[N_CH];
//   integer i;
//   always @(posedge clk) begin
//     if (!resetn) begin
//       for (i = 0; i < N_CH; i = i + 1) begin
//         vol[i] <= 3'b0;
//       end
//     end else begin
//       ready <= valid;
//       rdata <= vol[addr[4:2]];
//       if (wstrb[0]) vol[addr[4:2]] <= wdata[2:0];
//     end
//   end

//   // Mixier Body
//   reg [15:0] accum;
//   always @(posedge clk) begin
//     accum <= (ch[0] << vol[0]) + ((1000000 - (1 << vol[0])) << 7)
//            + (ch[1] << vol[1]) + ((1000000 - (1 << vol[1])) << 7)
//            + (ch[2] << vol[2]) + ((1000000 - (1 << vol[2])) << 7)
//            + (ch[3] << vol[3]) + ((1000000 - (1 << vol[3])) << 7);
//     out <= accum[15:4];  // Use upper 12bit
//   end

// endmodule
