module clock_gen #(
  parameter CLKI_DIV  = 1,
  parameter CLKFB_DIV = 1,
  parameter CLKOP_DIV = 1,
  parameter CLKOP_CPHASE = 0
) (
  input  wire clk_in,
  output wire clk_out,
  output reg  clk_locked
);

  wire locked;

  (* ICP_CURRENT="12" *)
  (* LPF_RESISTOR="8" *)
  (* MFG_ENABLE_FILTEROPAMP="1" *)
  (* MFG_GMCREF_SEL="2" *)
  EHXPLLL #(
    .PLLRST_ENA("DISABLED"),
    .INTFB_WAKE("DISABLED"),
    .STDBY_ENABLE("DISABLED"),
    .DPHASE_SOURCE("DISABLED"),
    .OUTDIVIDER_MUXA("DIVA"),
    .OUTDIVIDER_MUXB("DIVB"),
    .OUTDIVIDER_MUXC("DIVC"),
    .OUTDIVIDER_MUXD("DIVD"),
    .CLKI_DIV(CLKI_DIV),
    .CLKOP_ENABLE("ENABLED"),
    .CLKOP_DIV(CLKOP_DIV),
    .CLKOP_CPHASE(CLKOP_CPHASE),
    .CLKOP_FPHASE(0),
    .FEEDBK_PATH("CLKOP"),
    .CLKFB_DIV(CLKFB_DIV)
  ) pll_i (
    .RST(1'b0),
    .STDBY(1'b0),
    .CLKI(clk_in),
    .CLKOP(clk_out),
    .CLKFB(clk_out),
    .CLKINTFB(),
    .PHASESEL0(1'b0),
    .PHASESEL1(1'b0),
    .PHASEDIR(1'b1),
    .PHASESTEP(1'b1),
    .PHASELOADREG(1'b1),
    .PLLWAKESYNC(1'b0),
    .ENCLKOP(1'b0),
    .LOCK(locked)
  );

  reg locked_sync;
  always @(posedge clk_out) begin
    locked_sync <= locked;
    clk_locked <= locked_sync;
  end

endmodule

module top(
  input clk_25mhz,
  input [6:0] btn,
  output [7:0] led,
  output [13:0] gp,
  output [13:0] gn,
);

  wire clk_125mhz;
  clock_gen #(
    .CLKI_DIV(1),
    .CLKFB_DIV(5),
    .CLKOP_DIV(5),
    .CLKOP_CPHASE(0)
  ) clock_gen_inst(
    .clk_in(clk_25mhz),
    .clk_out(clk_125mhz),
    .clk_locked()
  );

  reg [31:0] cnt = 0;
  reg led_status = 0;
  always @(posedge clk_125mhz) begin
    cnt <= cnt + 1;
    if (cnt == 125000000) begin
      led_status <= ~led_status;
      cnt <= 0;
    end
  end
  assign led = led_status;

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
