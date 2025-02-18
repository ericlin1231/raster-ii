yosys read_verilog $::env(BUILDDIR)/../Raster.sv top.v tmds_encoder.v
yosys synth_ecp5 -json $::env(BUILDDIR)/raster.json
