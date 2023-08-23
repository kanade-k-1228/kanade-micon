module tristate (
    inout  pin,
    input  iosel,
    input  out,
    output in
);

  SB_IO #(
      .PIN_TYPE(6'b1010_01),
      .PULLUP  (1'b0)
  ) iobuf (
      .PACKAGE_PIN(pin),
      .OUTPUT_ENABLE(iosel),
      .D_OUT_0(out),
      .D_IN_0(in)
  );

endmodule
