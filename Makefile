BUILDDIR ?= build
TARGET ?= ulx3s

.PHONY: all
all: $(BUILDDIR)/$(TARGET)/raster.bit

.PHONY: fmt
fmt:
	@scalafmt

$(BUILDDIR)/Raster.sv: $(shell find src/main/scala -type f)
	@sbt run

$(BUILDDIR)/$(TARGET):
	@mkdir -p $(BUILDDIR)/$(TARGET)

$(BUILDDIR)/$(TARGET)/raster.bit: $(BUILDDIR)/Raster.sv | $(BUILDDIR)/$(TARGET)
	@make -C synth/$(TARGET) BUILDDIR=$(CURDIR)/build/$(TARGET)

.PHONY: prog
prog: $(BUILDDIR)/Raster.sv | $(BUILDDIR)/$(TARGET)
	@make -C synth/$(TARGET) prog BUILDDIR=$(CURDIR)/build/$(TARGET)

.PHONY: clean
clean:
	@rm -rf build
