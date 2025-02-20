yosys read_verilog -sv $::env(BUILDDIR)/../Raster.sv
yosys read_verilog top.v tmds_encoder.v
yosys synth_ecp5 -json $::env(BUILDDIR)/raster.json
