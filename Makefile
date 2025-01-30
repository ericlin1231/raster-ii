BUILDDIR ?= build
TARGET ?= ulx3s

all: bitstream

fmt:
	@scalafmt

$(BUILDDIR)/Raster.sv: $(shell find src/main/scala -type f)
	@sbt run

$(BUILDDIR)/$(TARGET):
	@mkdir -p $(BUILDDIR)/$(TARGET)

bitstream: $(BUILDDIR)/Raster.sv $(BUILDDIR)/$(TARGET)
	@make -C synth/$(TARGET) BUILDDIR=$(CURDIR)/$(BUILDDIR)/$(TARGET)

prog: $(BUILDDIR)/Raster.sv $(BUILDDIR)/$(TARGET)
	@make -C synth/$(TARGET) prog BUILDDIR=$(CURDIR)/$(BUILDDIR)/$(TARGET)

clean:
	@rm -rf $(BUILDDIR)
