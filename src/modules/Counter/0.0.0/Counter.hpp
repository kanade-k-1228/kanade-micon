#pragma once
#include "cpu.hpp"
#include <stdint.h>

class Counter {
  volatile uint32_t* reg;
public:
  Counter(volatile uint32_t* addr) : reg(addr) {}

  // Set counter
  void set(uint32_t cnt) { reg[0] = cnt; }

  // Set counter by second
  void set_sec(uint32_t sec) { reg[0] = CLK_HZ * sec; }

  // Set counter by mili second
  void set_ms(uint32_t ms) { reg[0] = CLK_KHZ * ms; }

  // Sec counter by micro second
  void set_us(uint32_t us) { reg[0] = CLK_MHZ * us; }

  // Set conter by frequence
  void set_hz(uint32_t f) { reg[0] = CLK_HZ / f; }
};
