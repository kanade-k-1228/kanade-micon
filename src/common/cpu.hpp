#pragma once
#include <stdint.h>

constexpr uint32_t CLK_HZ = 16000000;
constexpr uint32_t CLK_KHZ = CLK_HZ / 1000;
constexpr uint32_t CLK_MHZ = CLK_KHZ / 1000;

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
void delay_us(uint32_t time_us);
void delay_ms(uint32_t time_ms);
