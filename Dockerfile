FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    yosys \
    nextpnr-ice40 \
    iverilog \
    fpga-icestorm \
    gtkwave \
    gcc-riscv64-unknown-elf \
    binutils-riscv64-unknown-elf \
    vim-common \
    && rm -rf /var/lib/apt/lists/*

# Build ICE tools
RUN git clone https://github.com/cliffordwolf/icestorm.git /tmp/icestorm && \
    cd /tmp/icestorm && \
    make -j$(nproc) && \
    cp icepack icetime /usr/local/bin/ && \
    cd / && rm -rf /tmp/icestorm
