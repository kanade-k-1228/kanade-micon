#pragma once
#include <stdint.h>

class Mixier {
  volatile uint32_t* reg;
public:
  Mixier(volatile uint32_t* addr) : reg(addr) {}

  // Volume (0 ~ 15)
  void set_vol(uint32_t ch, uint32_t vol) {
    if(0 <= ch && ch < 4) reg[ch] = vol;
  }
};
