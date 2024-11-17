#include "fw.hpp"

void init() {
}

void loop() {
  for(;;) {
    gpio.write(1);
    delay_ms(1);
    gpio.write(0);
    delay_ms(1);
  }
}

uint32_t* irq(uint32_t* regs, uint32_t irqs) {
  static uint32_t irq_counts[32] = {0};
  serial.print("\nIRQ:");
  for(uint32_t i = 0; i < 32; ++i) {
    if((irqs & (1 << i)) != 0) {
      ++irq_counts[i];
      serial.print(" #");
      serial.print(i);
      serial.print("#");
      serial.print(irq_counts[i]);
    }
  }
  serial.print("\n");
  return regs;
}
