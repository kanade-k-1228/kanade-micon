#include "cpu.hpp"
#include "spirom/ROM_CFG.hpp"
/* includes */
#include "counter/Counter.hpp"
#include "gpio/GPIO.hpp"
#include "mixier/Mixier.hpp"
#include "oscilator/Oscilator.hpp"
#include "pwm/PWM.hpp"
#include "selector/Selector.hpp"
#include "spidac/SPIDAC.hpp"
#include "uart/UART.hpp"
/* end */

extern ROM_CFG rom_cfg;
/* declarations */
extern UART serial;
extern GPIO gpio;
extern PWM pwm;
extern Selector sel;
extern Oscilator square1;
extern Oscilator square2;
extern Oscilator square3;
extern Oscilator sawtooth;
extern Oscilator triangle;
extern Mixier mixier;
extern Counter sampling;
extern SPIDAC dac;
/* end */

void init();
void loop();
extern "C" uint32_t* irq(uint32_t* regs, uint32_t irqs);
