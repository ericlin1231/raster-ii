yosys read_verilog top.v $::env(BUILDDIR)/../Raster.sv
yosys synth_ecp5 -json $::env(BUILDDIR)/raster.json
