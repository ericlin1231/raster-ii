TARGET = radiona_ulx3s
DEVICE = LFE5U-85F
SDRAM = W9825G6KH6
BUS ?= axi-lite
CPU ?= vexriscv
VARIANT ?= minimal+debug

all: FORCE
	@python3 -m litex_boards.targets.$(TARGET) \
        --device $(DEVICE) --sdram-module $(SDRAM) \
        --bus-standard $(BUS) --cpu-type $(CPU) \
        --cpu-variant $(VARIANT) --build --load
FORCE:
