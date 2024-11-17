module Counter (
    input wire clk,
    input wire resetn,

    input wire valid,
    output reg ready,
    input wire [3:0] wstrb,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output reg [31:0] rdata,

    output reg [31:0] cnt,
    output reg of
);

  reg [31:0] max;
  always @(posedge clk) begin
    if (!resetn) begin
      max <= 0;
    end else begin
      ready <= valid;
      rdata <= max;
      if (wstrb[0]) max[7:0] <= wdata[7:0];
      if (wstrb[1]) max[15:8] <= wdata[15:8];
      if (wstrb[2]) max[23:16] <= wdata[23:16];
      if (wstrb[3]) max[31:24] <= wdata[31:24];
    end
  end

  always @(posedge clk) begin
    if (!resetn) begin
      cnt <= 0;
      of  <= 0;
    end else begin
      case (cnt == max)
        0: begin
          cnt <= cnt + 1;
          of  <= 0;
        end
        1: begin
          cnt <= 32'b0;
          of  <= 1;
        end
      endcase
    end
  end

endmodule
