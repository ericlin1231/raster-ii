module top(
  input clk_25mhz,
  input btn_pwrn,
  output [3:0] gpdi_dp
);

  wire [7:0] r, g, b;
  wire hsync, vsync, de;
  Raster raster(
    .clock(clk_25mhz),
    .reset(~btn[0]),
    .io_r(r),
    .io_g(g),
    .io_b(b),
    .io_ctrl_x(),
    .io_ctrl_y(),
    .io_ctrl_hsync(hsync),
    .io_ctrl_vsync(vsync),
    .io_ctrl_de(de)
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
  ) pll (
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

  wire [9:0] tmds_r, tmds_g, tmds_b;
  tmds_encoder tmds_encoder_r(
    .clk(clk_25mhz),
    .data(r),
    .ctrl({vsync, hsync}),
    .de(de),
    .tmds(tmds_r)
  );
  tmds_encoder tmds_encoder_g(
    .clk(clk_25mhz),
    .data(g),
    .ctrl(2'b00),
    .de(de),
    .tmds(tmds_g)
  );
  tmds_encoder tmds_encoder_b(
    .clk(clk_25mhz),
    .data(b),
    .ctrl(2'b00),
    .de(de),
    .tmds(tmds_b)
  );

  reg [9:0] tmds_shift_r, tmds_shift_g, tmds_shift_b;
  reg [4:0] tmds_shift = 1;
  always @(posedge clk_125mhz) begin
    tmds_shift <= {tmds_shift[3:0], tmds_shift[4]};
    tmds_shift_r <= tmds_shift[4] ? tmds_r : tmds_shift_r >> 2;
    tmds_shift_g <= tmds_shift[4] ? tmds_g : tmds_shift_g >> 2;
    tmds_shift_b <= tmds_shift[4] ? tmds_b : tmds_shift_b >> 2;
  end

  ODDRX1F ddr_r(
    .D0(tmds_shift_r[0]),
    .D1(tmds_shift_r[1]),
    .SCLK(clk_125mhz),
    .RST(0),
    .Q(gpdi_dp[2])
  );
  ODDRX1F ddr_g(
    .D0(tmds_shift_g[0]),
    .D1(tmds_shift_g[1]),
    .SCLK(clk_125mhz),
    .RST(0),
    .Q(gpdi_dp[1])
  );
  ODDRX1F ddr_b(
    .D0(tmds_shift_b[0]),
    .D1(tmds_shift_b[1]),
    .SCLK(clk_125mhz),
    .RST(0),
    .Q(gpdi_dp[0])
  );
  assign gpdi_dp[3] = clk_125mhz;

endmodule
