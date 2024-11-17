module RAM #(
    parameter integer WORDS = 256
) (
    input wire clk,
    input wire resetn,

    input wire valid,
    output reg ready,
    input wire [3:0] wstrb,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output reg [31:0] rdata
);
  reg [31:0] mem[0:WORDS-1];
  always @(posedge clk) begin
    ready <= valid;
    rdata <= mem[addr[23:2]];
    if (wstrb[0]) mem[addr[23:2]][7:0] <= wdata[7:0];
    if (wstrb[1]) mem[addr[23:2]][15:8] <= wdata[15:8];
    if (wstrb[2]) mem[addr[23:2]][23:16] <= wdata[23:16];
    if (wstrb[3]) mem[addr[23:2]][31:24] <= wdata[31:24];
  end
endmodule
