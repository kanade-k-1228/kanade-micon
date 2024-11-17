#pragma once
#include <stdint.h>

class GPIO {
  volatile uint32_t* reg;
  enum Regs {
    Reg_IOSEL = 0,
    Reg_OUT = 1,
    Reg_IN = 2
  };
public:
  enum Mode {
    IN = 0,
    OUT = 1
  };
public:
  GPIO(volatile uint32_t* addr) : reg(addr) {}

  // Select Input (Mode::IN) or Output (Mode::OUT)
  void set_mode(Mode mode) { reg[Reg_IOSEL] = mode; }

  // Read value (Mode::IN)
  uint32_t read() { return reg[Reg_IN]; }

  // Write value (Mode::OUT)
  void write(uint32_t val) { reg[Reg_OUT] = val; }
};
