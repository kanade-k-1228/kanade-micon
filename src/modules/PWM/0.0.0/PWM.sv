module PWM (
    input wire clk,
    input wire resetn,

    input wire valid,
    output reg ready,
    input wire [3:0] wstrb,
    input wire [31:0] addr,
    input wire [31:0] wdata,
    output reg [31:0] rdata,

    output reg out
);
  reg [ 7:0] counter;
  reg [31:0] threshold;
  always @(posedge clk) begin
    if (!resetn) begin
      counter <= 0;
      threshold <= 0;
      out <= 0;
    end else begin
      // registor
      ready <= valid;
      rdata <= threshold;
      if (wstrb[0]) threshold[7:0] <= wdata[7:0];
      if (wstrb[1]) threshold[15:8] <= wdata[15:8];
      if (wstrb[2]) threshold[23:16] <= wdata[23:16];
      if (wstrb[3]) threshold[31:24] <= wdata[31:24];
      // pwm
      counter <= counter + 1;
      if (counter < threshold) out <= 1;
      else out <= 0;
    end
  end
endmodule
