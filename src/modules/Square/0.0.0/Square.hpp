#pragma once
#include "cpu.hpp"
#include <stdint.h>

class Square {
  volatile uint32_t* reg;
public:
  Square(volatile uint32_t* addr) : reg(addr) {}
  void set(uint32_t clk) { reg[0] = clk; }

  /// @brief Set oscilating clock counter
  /// @param clk
  void freq(uint32_t f) { reg[0] = CLK_HZ / 2 / f; }

  /// @brief Stop oscilating
  void stop() { reg[0] = 0; }
};
