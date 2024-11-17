module Square (
    input wire clk,
    input wire resetn,

    input wire valid,
    output reg ready,
    input wire [3:0] wstrb,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output reg [31:0] rdata,

    output wire [7:0] out
);

  reg [31:0] threshold;
  reg [31:0] counter;
  reg _out;

  always @(posedge clk) begin
    if (!resetn) begin
      threshold <= 0;
      counter <= 0;
      _out <= 0;
    end else begin
      ready <= valid;
      rdata <= threshold;
      if (wstrb[0]) threshold[7:0] <= wdata[7:0];
      if (wstrb[1]) threshold[15:8] <= wdata[15:8];
      if (wstrb[2]) threshold[23:16] <= wdata[23:16];
      if (wstrb[3]) threshold[31:24] <= wdata[31:24];

      // Wave Generator
      if (|wstrb) begin  // Reset (on CSR Updated)
        _out <= 0;
        counter <= 0;
      end else if (threshold == 0) begin  // Stop
        counter <= 0;
        _out <= 0;
      end else if (counter == threshold) begin  // Switchs
        _out <= !_out;
        counter <= 0;
      end else begin
        counter <= counter + 1;
      end
    end
  end

  assign out = _out ? 8'b1000_0000 : 8'b0000_0000;

endmodule
