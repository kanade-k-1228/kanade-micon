#include "firmware.hpp"

void init() {
  gpio_blink(gpio);
}

void loop() {}

uint32_t* irq(uint32_t* regs, uint32_t irqs) {
  static uint32_t irq_counts[32] = {0};
  serial << "\nIRQ:";
  for(uint32_t i = 0; i < 32; ++i) {
    if((irqs & (1 << i)) != 0) {
      ++irq_counts[i];
      serial << " #" << i << "*" << irq_counts[i];
    }
  }
  serial << "\n";
  return regs;
}
