#include "firmware.hpp"

ROM_CFG rom_cfg((volatile uint32_t*)0x0200'0000);
/* definitions */
UART uart((volatile uint32_t*)0x0300'0000);
GPIO gpio((volatile uint32_t*)0x0400'0000);
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
