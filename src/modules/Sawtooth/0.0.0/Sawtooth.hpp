#pragma once
#include "cpu.hpp"
#include <stdint.h>

class Sawtooth {
  volatile uint32_t* reg;
public:
  Sawtooth(volatile uint32_t* addr) : reg(addr) {}
  void set(uint32_t clk) { reg[0] = clk; }

  /// @brief Start oscilating
  void freq(uint32_t f) { reg[0] = CLK_HZ / 256 / f; }

  /// @brief Stop oscilating
  void stop() { reg[0] = 0; }
};
