module top(
  input clk_25mhz,
  input [6:0] btn,
  output [7:0] led,
);

  reg [7:0] o_led;

  Raster raster(
    .clock(clk_25mhz),
    .reset(~btn[0]),
    .io_led(o_led)
  );

  assign led = o_led;

endmodule
