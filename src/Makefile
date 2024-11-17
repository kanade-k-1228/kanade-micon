ARCH = riscv64-unknown-elf-
SOFTWARE  = common/*.cpp modules/*/*/*.cpp fw/*.cpp sw/*.cpp
HARDWARE  = common/*.sv  modules/*/*/*.sv hw/top.sv
SIMU_HARD = common/simu/*.sv simu/*.sv
SIMU_SOFT = common/*.cpp modules/*/*/*.cpp fw/*.cpp simu/*.cpp
NPROC     = $(shell nproc)

upload: hw sw
# Linux
#	tinyprog -p .build/hardware.bin -u .build/software.bin
# Windows with WSL
	powershell.exe -c \
	"tinyprog -p \$$env:WSLHome\kanade-micon\src\.build\hardware.bin \
	          -u \$$env:WSLHome-micon\src\.build\software.bin"

hw: build/hw.bin
build/hw.bin: $(HARDWARE)
# Synthesis
	yosys -ql build/hw.json.log -p 'synth_ice40 -top top -json build/hw.json' $^
# Place & Route
	nextpnr-ice40 -ql build/hw.asc.log --threads $(NPROC) \
		--lp8k --package cm81 --asc build/hw.asc \
		--pcf common/fpga.pcf --json build/hw.json
# Timing Analysis
	icetime -d lp8k -c 12 -mtr build/hw.rpt build/hw.asc
# Package into a binary file
	icepack build/hw.asc build/hw.bin

sw: build/sw.bin
build/sw.bin: common/start.S $(SOFTWARE)
# Compile
	$(ARCH)g++ -march=rv32im -mabi=ilp32 -nostartfiles \
	        -Wl,-Bstatic,-T,.common/sections.lds,--strip-debug,-Map=build/sw.map,--cref \
			-O3 -ffreestanding -nostdlib -I common -I fw -I modules -o build/sw.elf $^
# Object Dump
	$(ARCH)objdump --demangle -D build/sw.elf > build/sw.objdump
# Symbol Table
	$(ARCH)nm --demangle --numeric-sort build/sw.elf > build/sw.nm
# Generate Binary
	$(ARCH)objcopy -O binary build/sw.elf /dev/stdout > build/sw.bin

build/simu_flash.hex: common/start.S $(SIMU_SOFT)
# Compile
	$(ARCH)g++ -march=rv32im -mabi=ilp32 -nostartfiles \
	        -Wl,-Bstatic,-T,common/sections.lds,--strip-debug,-Map=build/simu_sw.map,--cref \
			-O3 -ffreestanding -nostdlib -I common -I fw -I modules -o build/simu_sw.elf $^ \
			-DSIMU
# Object Dump
	$(ARCH)objdump --demangle -D build/simu_sw.elf > build/simu_sw.objdump
# Symbol Table
	$(ARCH)nm --demangle --numeric-sort build/simu_sw.elf > build/simu_sw.nm
# Generate Binary
	$(ARCH)objcopy -O binary build/simu_sw.elf build/simu_sw.bin
	xxd build/simu_sw.bin > build/simu_sw.hex
# Flash binary
	common/simu/zeropadding.sh build/simu_sw.bin > build/simu_flash.bin
	xxd -c 1 -p build/simu_flash.bin > build/simu_flash.hex

build/simu.vcd: build/simu_flash.hex $(SIMU_HARD) $(HARDWARE)
	iverilog -g2005-sv -s tb -o build/simu_tb.vvp $(SIMU_HARD) $(HARDWARE) \
	         `yosys-config --datdir/ice40/cells_sim.v` \
			 -DNO_ICE40_DEFAULT_ASSIGNMENTS \
			 -DDEBUG -DDEBUGNETS -DDEBUGREGS
	vvp build/simu_tb.vvp > build/simu.log
	common/simu/serial.sh build/simu.log build/simu_serial.log

#	verilator --cc --exe --build -j 8 --trace -DSIMULATION \
				-Icommon -Imodules -Ifw -I. -o $@ --timing \
				$(SIMU_HARD) $(HARDWARE) ~/oss-cad-suite/share/yosys/ice40/cells_sim.v

simu: build/simu.vcd
	gtkwave build/simu.vcd

.PHONY: upload hw sw simu
