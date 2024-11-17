#include "SPIROM.hpp"
#include "cpu.hpp"
/* includes */
#include "Counter/0.0.0/Counter.hpp"
#include "GPIO/0.0.0/GPIO.hpp"
#include "Mixier/0.0.0/Mixier.hpp"
#include "PWM/0.0.0/PWM.hpp"
#include "SPIDAC/0.0.0/SPIDAC.hpp"
#include "Sawtooth/0.0.0/Sawtooth.hpp"
#include "Square/0.0.0/Square.hpp"
#include "Triangle/0.0.0/Triangle.hpp"
#include "UART/0.0.0/UART.hpp"
/* end */

extern ROM rom_cfg;
/* declarations */
extern UART serial;
extern GPIO gpio;
extern PWM pwm;
extern Square square1;
extern Square square2;
extern Square square3;
extern Sawtooth sawtooth;
extern Triangle triangle;
extern Mixier mixier;
extern Counter sampling;
extern SPIDAC dac;
/* end */

void init();
void loop();
extern "C" uint32_t* irq(uint32_t* regs, uint32_t irqs);
