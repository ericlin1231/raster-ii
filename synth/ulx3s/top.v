module top(
  input clk_25mhz,
  input [6:0] btn,
  output [7:0] led,
  output [13:0] gp,
  output [13:0] gn,
);

  wire clk_125mhz;
  (* FREQUENCY_PIN_CLKI="25" *)
  (* FREQUENCY_PIN_CLKOP="125" *)
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
    .CLKI_DIV(1),
    .CLKOP_ENABLE("ENABLED"),
    .CLKOP_DIV(5),
    .CLKOP_CPHASE(2),
    .CLKOP_FPHASE(0),
    .FEEDBK_PATH("CLKOP"),
    .CLKFB_DIV(5)
  ) pll_i (
    .RST(1'b0),
    .STDBY(1'b0),
    .CLKI(clk_25mhz),
    .CLKOP(clk_125mhz),
    .CLKFB(clk_125mhz),
    .CLKINTFB(),
    .PHASESEL0(1'b0),
    .PHASESEL1(1'b0),
    .PHASEDIR(1'b1),
    .PHASESTEP(1'b1),
    .PHASELOADREG(1'b1),
    .PLLWAKESYNC(1'b0),
    .ENCLKOP(1'b0),
    .LOCK()
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

  wire [3:0] r;
  wire [3:0] g;
  wire [3:0] b;
  Raster raster(
    .clock(clk_25mhz),
    .reset(~btn[0]),
    .io_r(r),
    .io_g(g),
    .io_b(b),
    .io_ctrl_x(),
    .io_ctrl_y(),
    .io_ctrl_hsync(gp[3]),
    .io_ctrl_vsync(gp[2]),
    .io_ctrl_de()
  );
  assign gn[10:7] = {r[0], r[1], r[2], r[3]};
  assign gn[3:0] = {g[0], g[1], g[2], g[3]};
  assign gp[10:7] = {b[0], b[1], b[2], b[3]};

endmodule
