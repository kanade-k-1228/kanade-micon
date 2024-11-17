//////////////////////////////////////////////////////////////////
// SPI DAC MPC49x1 ///////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
//       : _  :_   _   _   _   _   _   _  :_   _   _   _   _    //
// clk   :  |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_  //
//       :    :___           _:__         :           :         //
// wstrb : __|:   |_________| :  |________:___________:________ //
//       :    :               x           :           :         //
// state : w  | sending                   | ending    | waiting //
//       :    :                           :           :         //
// cnt   : -  | 0     | 1     |...| 15    | 0 | 1 | 2 :         //
//       : ___:   :   :                   :___________:________ //
// cs    :    |___:___:___________________|           :         //
//       :    :    ___:    ___         ___:           :         //
// scl   : ___:___|   |___|   |...|___|   |___________:________ //
//       :    :   :   :                   :           :         //
// sdi   : -  | 0     | [14]  |...| [0]   : -         :         //
//       : ___:___:___:___________________:___        :________ //
// ldac  :    :   :   :                   :   |_______|         //
//       :    :   :   :                   :           :         //
//      [I]  [S] [A] [B]                 [E][E'][E''][F]        //
//////////////////////////////////////////////////////////////////

// 送信は wstrb または sample によって開始されます。
// wstrb にトリガされた場合は、メモリから送られてきた 2バイト をそのまま送信します。
// sample にトリガされた場合は、in 入力 12 ビットと、内部レジスタの上位4ビットを送信します。
// 内部レジスタ dsend には、前回送信した内容が含まれています。

module SPIDAC (
    input wire clk,
    input wire resetn,

    input wire valid,
    output reg ready,
    input wire [31:0] addr,
    input wire [3:0] wstrb,
    input wire [31:0] wdata,
    output reg [31:0] rdata,

    input wire sample,
    input wire [11:0] in,

    output reg cs,
    output reg scl,
    output reg sdi,
    output reg ldac
);

  reg [15:0] dsend;
  reg [ 2:0] state;
  reg [ 3:0] cnt;

  parameter waiting = 3'b001;
  parameter sending = 3'b010;
  parameter ending = 3'b100;

  always @(posedge clk) begin
    if (!resetn) begin  // [I] Initial state
      state <= waiting;
      dsend <= {
        1'b0,
        1'b1,  // BUF
        1'b1,  // GA
        1'b1,  // SHDN
        12'b0
      };
      cs <= 1;
      scl <= 0;
      sdi <= 0;
      ldac <= 1;
    end else begin
      ready <= valid;
      rdata <= {16'b0, dsend};
      case (state)
        waiting: begin
          if (|wstrb || sample) begin  // [S] Start sending
            // Latch send data
            dsend <= |wstrb ? wdata[15:0] : {dsend[15:12], in};
            // Start sending
            state <= sending;
            cnt <= 0;
            cs <= 0;
            scl <= 0;
            sdi <= |wstrb ? wdata[15] : dsend[15];
          end
        end
        sending: begin
          case (scl)
            0: begin  // [A]
              scl <= 1;
            end
            1: begin
              if (cnt == 15) begin  // [E] ending
                state <= ending;
                cs <= 1;
                cnt <= 0;
              end else begin  // [B]
                scl <= 0;
                cnt <= cnt + 1;
                sdi <= dsend[14-cnt];
              end
            end
          endcase
        end
        ending: begin
          case (cnt)
            0: begin
              cnt  <= cnt + 1;
              ldac <= 0;
            end
            1: begin
              cnt <= cnt + 1;
            end
            2: begin
              state <= waiting;
              ldac  <= 1;
            end
          endcase
        end
      endcase
    end
  end
endmodule
