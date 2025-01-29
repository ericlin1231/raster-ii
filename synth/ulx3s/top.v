module top(
  input clk_25mhz,
  input [6:0] btn,
  output [13:0] gp,
  output [13:0] gn,
);

  reg [3:0] r;
  reg [3:0] g;
  reg [3:0] b;
  Raster raster(
    .clock(clk_25mhz),
    .reset(~btn[0]),
    .io_vga_r(r),
    .io_vga_g(g),
    .io_vga_b(b),
    .io_vga_hsync(gp[3]),
    .io_vga_vsync(gp[2]),
  );
  assign gn[10:7] = {r[0], r[1], r[2], r[3]};
  assign gn[3:0] = {g[0], g[1], g[2], g[3]};
  assign gp[10:7] = {b[0], b[1], b[2], b[3]};

endmodule
