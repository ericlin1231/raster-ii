all: $(BUILDDIR)/raster.bit

$(BUILDDIR)/raster.json: raster.tcl top.v
	@yosys -c $<

$(BUILDDIR)/raster.config: $(BUILDDIR)/raster.json ulx3s.lpf
	@nextpnr-ecp5 --85k \
		--json $(word 1,$^) \
		--lpf $(word 2,$^) \
		--textcfg $@

$(BUILDDIR)/raster.bit: $(BUILDDIR)/raster.config
	@ecppack $< $@ --compress

.PHONY: prog
prog: $(BUILDDIR)/raster.bit
	@openFPGALoader -b ulx3s $(BUILDDIR)/raster.bit
