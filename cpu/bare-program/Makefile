all: src
	@cargo objcopy --release -- -O binary program.bin
	@litex_term --kernel program.bin $(PORT)
