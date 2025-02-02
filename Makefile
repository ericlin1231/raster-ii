BUILDDIR ?= build
TARGET ?= ulx3s

all: synth

fmt:
	@scalafmt

$(BUILDDIR)/Raster.sv: $(shell find src/main/scala -type f)
	@sbt run

$(BUILDDIR)/%:
	@mkdir -p $@

.PHONY: sim
sim: $(BUILDDIR)/Raster.sv $(BUILDDIR)/sim
	@make -C sim run BUILDDIR=$(CURDIR)/$(BUILDDIR)/sim

synth: $(BUILDDIR)/Raster.sv $(BUILDDIR)/$(TARGET)
	@make -C synth/$(TARGET) BUILDDIR=$(CURDIR)/$(BUILDDIR)/$(TARGET)

prog: $(BUILDDIR)/Raster.sv $(BUILDDIR)/$(TARGET)
	@make -C synth/$(TARGET) prog BUILDDIR=$(CURDIR)/$(BUILDDIR)/$(TARGET)

clean:
	@rm -rf $(BUILDDIR)
