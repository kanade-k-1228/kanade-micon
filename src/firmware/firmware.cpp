#include "firmware.hpp"

ROM_CFG rom_cfg((volatile uint32_t*)0x0200'0000);
/* definitions */
UART serial((volatile uint32_t*)0x0300'0000);
GPIO gpio((volatile uint32_t*)0x0400'0000);
PWM pwm((volatile uint32_t*)0x0500'0000);
Selector sel((volatile uint32_t*)0x0600'0000);
Oscilator square1((volatile uint32_t*)0x0700'0000);
Oscilator square2((volatile uint32_t*)0x0800'0000);
Oscilator square3((volatile uint32_t*)0x0900'0000);
Oscilator sawtooth((volatile uint32_t*)0x0A00'0000);
Oscilator triangle((volatile uint32_t*)0x0B00'0000);
Mixier mixier((volatile uint32_t*)0x0C00'0000);
Counter sampling((volatile uint32_t*)0x0D00'0000);
SPIDAC dac((volatile uint32_t*)0x0E00'0000);
/* end */

void main() {
  init_data();
  init_bss();
  init_array();

#ifndef SIMU
  rom_cfg.dual_io();
#endif

  init();
  for(;;) loop();
}
