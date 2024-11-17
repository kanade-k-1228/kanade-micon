#pragma once
#include <stdint.h>

class Reg {
private:
  volatile uint32_t* reg;
public:
  Reg(volatile uint32_t* addr) { reg = addr; }
  inline void addr(volatile uint32_t* addr) { reg = addr; }
  inline void set(uint32_t val) { reg[0] = val; }
  inline void set(uint32_t word, uint32_t val) { reg[word] = val; }
  inline uint32_t get(uint32_t word = 0) { return reg[word]; }
};
