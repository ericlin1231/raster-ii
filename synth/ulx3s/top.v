module top(
  input clk_25mhz,
  input [6:0] btn,
  output [13:0] gp,
  output [13:0] gn,
);

  Raster raster(
    .clock(clk_25mhz),
    .reset(~btn[0]),
    .io_vga_r(gn[10:7]),
    .io_vga_g(gn[3:0]),
    .io_vga_b(gp[10:7]),
    .io_vga_hsync(gp[3]),
    .io_vga_vsync(gp[2]),
  );

endmodule
