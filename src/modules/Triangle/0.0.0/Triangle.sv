module Triangle (
    input wire clk,
    input wire resetn,

    input wire valid,
    output reg ready,
    input wire [3:0] wstrb,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output reg [31:0] rdata,

    output reg [7:0] out
);

  reg [31:0] threshold;
  reg [31:0] counter;
  reg direct;  // 0=Step Up, 1=Step Down

  always @(posedge clk) begin
    if (!resetn) begin
      threshold <= 0;
      counter <= 0;
      out <= 0;
      direct <= 0;
    end else begin
      ready <= valid;
      rdata <= threshold;
      if (wstrb[0]) threshold[7:0] <= wdata[7:0];
      if (wstrb[1]) threshold[15:8] <= wdata[15:8];
      if (wstrb[2]) threshold[23:16] <= wdata[23:16];
      if (wstrb[3]) threshold[31:24] <= wdata[31:24];

      // Wave Generator
      // on CSR Updated
      if (|wstrb) begin  // Reset
        out <= 0;
        counter <= 0;
        direct <= 0;
      end else if (threshold == 0) begin  // Stop
        counter <= 0;
        out <= 0;
      end else if (counter == threshold) begin  // Step up / down
        counter <= 0;
        if (out == 8'hFF) begin
          out <= 8'hFE;
          direct <= 1;
        end else if (out == 8'h00) begin
          out <= 8'h01;
          direct <= 0;
        end else begin
          out <= direct ? (out - 1) : (out + 1);
        end
      end else begin
        counter <= counter + 1;
      end
    end
  end

endmodule
