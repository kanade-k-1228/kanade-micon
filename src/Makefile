CROSS = riscv64-unknown-elf-
SOFTWARE  = .common/*.cpp .packages/*/*.cpp firmware/*.cpp software/*.cpp
HARDWARE  = .common/*.v   .packages/*/*.v   hardware/hardware.v 
SIMU_HARD = .common/simulation/*.v simulation/*.v
SIMU_SOFT = .common/*.cpp .packages/*/*.cpp firmware/*.cpp simulation/*.cpp

upload: hardware software
#	tinyprog -p .build/hardware.bin -u .build/software.bin
	powershell.exe -c \
	"tinyprog -p \$$env:WSLHome\my-micon\src\.build\hardware.bin \
	          -u \$$env:WSLHome\my-micon\src\.build\software.bin"

gen: hardware/hardware.v firmware/firmware.hpp firmware/firmware.cpp
	micon read -m micon.mcl
hardware/hardware.v: micon.mcl
	micon gen-hard -t $@ -m $^ -o $@
firmware/firmware.hpp: micon.mcl
	micon gen-firm -t $@ -m $^ -o $@
firmware/firmware.cpp: micon.mcl
	micon gen-firm -t $@ -m $^ -o $@

hardware: .build/hardware.bin
.build/hardware.json: $(HARDWARE)
	yosys -ql $@.log -p 'synth_ice40 -top hardware -json $@' $^
.build/hardware.asc: .build/hardware.json
	nextpnr-ice40 -ql $@.log --lp8k --package cm81 --asc $@ --pcf .common/fpga.pcf --json $^
.build/hardware.bin: .build/hardware.asc
	icetime -d lp8k -c 12 -mtr .build/hardware.rpt $^
	icepack $^ $@

software: .build/software.objdump .build/software.nm .build/software.bin
.build/software.elf: .common/start.S $(SOFTWARE) firmware/firmware.hpp
	$(CROSS)g++ -march=rv32imc -mabi=ilp32 -nostartfiles \
	        -Wl,-Bstatic,-T,.common/sections.lds,--strip-debug,-Map=.build/software.map,--cref \
			-O3 -ffreestanding -nostdlib -I .common -I firmware -I .packages -o $@ $^
.build/software.objdump: .build/software.elf
	$(CROSS)objdump --demangle -D $^ > $@
.build/software.nm: .build/software.elf
	$(CROSS)nm --demangle --numeric-sort $^ > $@
.build/software.bin: .build/software.elf
	$(CROSS)objcopy -O binary $^ /dev/stdout > $@

.build/simu_software.elf: .common/start.S $(SIMU_SOFT)
	$(CROSS)g++ -march=rv32imc -mabi=ilp32 -nostartfiles \
	        -Wl,-Bstatic,-T,.common/sections.lds,--strip-debug,-Map=.build/simu_software.map,--cref \
			-O3 -ffreestanding -nostdlib -I .common -I firmware -I .packages -o $@ $^ \
			-DSIMU
.build/simu_software.objdump: .build/simu_software.elf
	$(CROSS)objdump --demangle -D $^ > $@
.build/simu_software.nm: .build/simu_software.elf
	$(CROSS)nm --demangle --numeric-sort $^ > $@
.build/simu_software.bin: .build/simu_software.elf
	$(CROSS)objcopy -O binary $^ $@
.build/simu_software.hex: simu_.build/software.bin
	xxd $^ > $@
.build/simu_flash.bin: .build/simu_software.bin
	.common/simulation/zeropadding.sh $^ > $@
.build/simu_flash.hex: .build/simu_flash.bin
	xxd -c 1 -p $^ > $@
.build/simu_testbench.vvp: .build/simu_flash.hex $(SIMU_HARD) $(HARDWARE)
	iverilog -g2005-sv -s testbench -o $@ $(SIMU_HARD) $(HARDWARE) \
	         `yosys-config --datdir/ice40/cells_sim.v` \
			 -DNO_ICE40_DEFAULT_ASSIGNMENTS \
			 -DDEBUG -DDEBUGNETS -DDEBUGREGS
.build/simulation.vcd: .build/simu_testbench.vvp
	vvp $^ > .build/simulation.log
	.common/simulation/serial.sh .build/simulation.log .build/simu_serial.log
simu: .build/simulation.vcd .build/simu_software.objdump .build/simu_software.nm
	gtkwave .build/simulation.vcd

.PHONY: upload gen hardware software simu
