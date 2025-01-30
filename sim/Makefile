all: $(BUILDDIR)/sim

$(BUILDDIR)/sim: FORCE
	@verilator \
		--build \
		--cc \
		--exe \
		-j 0 \
		-LDFLAGS -lSDL3 \
		-Mdir $(BUILDDIR) \
		-o sim \
		$(BUILDDIR)/../Raster.sv \
		$(CURDIR)/sim.cpp

FORCE:

run: $(BUILDDIR)/sim
	@$(BUILDDIR)/sim
