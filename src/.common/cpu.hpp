#pragma once
#include <stdint.h>
#define CLK_FREQ 16000000
#define RAM_END 0x2000
#define REG_NUM 32

extern uint32_t _init_data_start, _data_start, _data_end;
extern uint32_t _bss_start, _bss_end;
extern uint32_t _heap_start;
extern uint32_t _init_array_start, _init_array_end;

void init_data();
void init_bss();
void init_array();

__attribute__((naked)) uint32_t set_irq_mask(uint32_t mask);
__attribute__((naked)) uint32_t wait_irq();
__attribute__((naked)) uint32_t set_timer(uint32_t time);
uint32_t rdcycle_l();
uint32_t rdcycle_h();
uint32_t rdcycle(int32_t shift);

void delay(uint32_t time_h, uint32_t time_l);
void delayUs(uint32_t time_us);
void delayMs(uint32_t time_ms);
