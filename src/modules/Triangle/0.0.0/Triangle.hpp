#pragma once
#include "cpu.hpp"
#include <stdint.h>

class Triangle {
  volatile uint32_t* reg;
public:
  Triangle(volatile uint32_t* addr) : reg(addr) {}
  void set(uint32_t clk) { reg[0] = clk; }

  /// @brief Start oscilating
  /// @param note_no MIDI Note number (0~127)
  void freq(uint32_t f) { reg[0] = CLK_HZ / 256 / 2 / f; }

  /// @brief Stop oscilating
  void stop() { reg[0] = 0; }
};
