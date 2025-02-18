module top(
  input clk_25mhz,
  output [3:0] gpdi_dp
);

  wire clk_pix, clk_pix_5x, clk_pix_locked;
  (* FREQUENCY_PIN_CLKI="25" *)
  (* FREQUENCY_PIN_CLKOP="125" *)
  (* FREQUENCY_PIN_CLKOS="25" *)
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
    .CLKOS_ENABLE("ENABLED"),
    .CLKOS_DIV(25),
    .CLKOS_CPHASE(2),
    .CLKOS_FPHASE(0),
    .FEEDBK_PATH("CLKOP"),
    .CLKFB_DIV(5)
  ) pll (
    .RST(1'b0),
    .STDBY(1'b0),
    .CLKI(clk_25mhz),
    .CLKOP(clk_pix_5x),
    .CLKOS(clk_pix),
    .CLKFB(clk_pix_5x),
    .CLKINTFB(),
    .PHASESEL0(1'b0),
    .PHASESEL1(1'b0),
    .PHASEDIR(1'b1),
    .PHASESTEP(1'b1),
    .PHASELOADREG(1'b1),
    .PLLWAKESYNC(1'b0),
    .ENCLKOP(1'b0),
    .LOCK(clk_pix_locked)
  );

  wire [7:0] r, g, b;
  wire hsync, vsync, de;
  Raster raster(
    .clock(clk_pix),
    .reset(~clk_pix_locked),
    .io_r(r),
    .io_g(g),
    .io_b(b),
    .io_ctrl_x(),
    .io_ctrl_y(),
    .io_ctrl_hsync(hsync),
    .io_ctrl_vsync(vsync),
    .io_ctrl_de(de)
  );

  wire [9:0] tmds_r, tmds_g, tmds_b;
  tmds_encoder tmds_encoder_r(
    .clk(clk_pix),
    .data(r),
    .ctrl(2'b00),
    .de(de),
    .tmds(tmds_r)
  );
  tmds_encoder tmds_encoder_g(
    .clk(clk_pix),
    .data(g),
    .ctrl(2'b00),
    .de(de),
    .tmds(tmds_g)
  );
  tmds_encoder tmds_encoder_b(
    .clk(clk_pix),
    .data(b),
    .ctrl({vsync, hsync}),
    .de(de),
    .tmds(tmds_b)
  );

  reg [9:0] tmds_shift_r, tmds_shift_g, tmds_shift_b;
  reg [4:0] tmds_shift;
  always @(posedge clk_pix_5x) begin
    tmds_shift <= ~clk_pix_locked ? 1'b1 : {tmds_shift[3:0], tmds_shift[4]};
    tmds_shift_r <= tmds_shift[4] ? tmds_r : tmds_shift_r >> 2;
    tmds_shift_g <= tmds_shift[4] ? tmds_g : tmds_shift_g >> 2;
    tmds_shift_b <= tmds_shift[4] ? tmds_b : tmds_shift_b >> 2;
  end

  ODDRX1F ddr_r(
    .D0(tmds_shift_r[0]),
    .D1(tmds_shift_r[1]),
    .SCLK(clk_pix_5x),
    .RST(1'b0),
    .Q(gpdi_dp[2])
  );
  ODDRX1F ddr_g(
    .D0(tmds_shift_g[0]),
    .D1(tmds_shift_g[1]),
    .SCLK(clk_pix_5x),
    .RST(1'b0),
    .Q(gpdi_dp[1])
  );
  ODDRX1F ddr_b(
    .D0(tmds_shift_b[0]),
    .D1(tmds_shift_b[1]),
    .SCLK(clk_pix_5x),
    .RST(1'b0),
    .Q(gpdi_dp[0])
  );
  assign gpdi_dp[3] = clk_pix;

endmodule
