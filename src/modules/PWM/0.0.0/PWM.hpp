#pragma once
#include <stdint.h>

class PWM {
  volatile uint32_t* reg;
public:
  PWM(volatile uint32_t* addr) : reg(addr) {}

  // Set duty ratio 0~255 (output voltage = val * (3.3V/256))
  void duty(uint32_t val) { reg[0] = val; }
};
