BUILDDIR ?= build
CPUDIR ?= cpu
TARGET ?= ulx3s
PORT ?= /dev/ttyUSB0

all: synth

fmt:
	@scalafmt

$(BUILDDIR)/Raster.sv: $(shell find src/main/scala -type f)
	@sbt run

$(BUILDDIR)/%:
	@mkdir -p $@

.PHONY: sim cpu
sim: $(BUILDDIR)/Raster.sv $(BUILDDIR)/sim
	@make -C sim run BUILDDIR=$(CURDIR)/$(BUILDDIR)/sim

synth: $(BUILDDIR)/Raster.sv $(BUILDDIR)/$(TARGET)
	@make -C synth/$(TARGET) BUILDDIR=$(CURDIR)/$(BUILDDIR)/$(TARGET)

prog: $(BUILDDIR)/Raster.sv $(BUILDDIR)/$(TARGET)
	@make -C synth/$(TARGET) prog BUILDDIR=$(CURDIR)/$(BUILDDIR)/$(TARGET)

flash: $(BUILDDIR)/Raster.sv $(BUILDDIR)/$(TARGET)
	@make -C synth/$(TARGET) flash BUILDDIR=$(CURDIR)/$(BUILDDIR)/$(TARGET)

cpu: FORCE
	@make -C $(CPUDIR)

cpu-test: $(CPUDIR)/bare-program
	@PORT=$(PORT) make -C $(CPUDIR)/bare-program

clean:
	@rm -rf $(BUILDDIR)

FORCE:
