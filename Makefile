.PHONY: all
all: build/raster.bit

.PHONY: fmt
fmt:
	@scalafmt

build/Raster.sv: $(shell find src/main/scala -type f)
	@sbt run

build/raster.json: synth/raster.ys synth/top.v build/Raster.sv
	@yosys $<

build/raster.config: build/raster.json synth/ulx3s_v20.lpf
	@nextpnr-ecp5 --85k \
		--json $(word 1,$^) \
		--lpf $(word 2,$^) \
		--textcfg $@

build/raster.bit: build/raster.config
	@ecppack $< $@

.PHONY: prog
prog:
	@openFPGALoader -b ulx3s build/raster.bit

.PHONY: clean
clean:
	@rm -rf build
