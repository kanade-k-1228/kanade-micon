#include "cpu.hpp"

void init_data() {
  for(uint32_t* dest = &_data_start; dest < &_data_end; ++dest) {
    *dest = *(&_init_data_start + (dest - &_data_start));
  }
}

void init_bss() {
  for(uint32_t* dest = &_bss_start; dest < &_bss_end; ++dest) {
    *dest = 0;
  }
}

void init_array() {
  for(volatile uint32_t* init = &_init_array_start; init < &_init_array_end; ++init) {
    ((void (*)(void)) * init)();
  }
}

__attribute__((naked)) uint32_t
set_irq_mask(uint32_t mask) {
  asm(
      ".global set_irq_mask\n"
      "set_irq_mask:\n"
      ".word 0x0605650B\n"
      "ret\n");
}
__attribute__((naked)) uint32_t
wait_irq() {
  asm(
      ".global wait_irq\n"
      "wait_irq:\n"
      ".word 0x0800650B\n"
      "ret\n");
}

__attribute__((naked)) uint32_t
set_timer(uint32_t time) {
  asm(
      ".global set_timer\n"
      "set_timer:\n"
      ".word 0x0A05650B\n"
      "ret\n");
}

uint32_t rdcycle_l() {
  uint32_t ret;
  __asm__ volatile(
      "rdcycle %0"
      : "=r"(ret));
  return ret;
}

uint32_t rdcycle_h() {
  uint32_t ret;
  __asm__ volatile(
      "rdcycleh %0"
      : "=r"(ret));
  return ret;
}

uint32_t rdcycle(int32_t shift) {
  return (rdcycle_h() << (32 - shift)) | (rdcycle_l() >> shift);
}

/// @brief Delay (time_h << 32 + time_l) * 62.5ns
/// @param time_h ≈ 4.5 min
/// @param time_l = 62.5 ns
void delay(uint32_t time_h, uint32_t time_l) {
  uint32_t start_h = rdcycle_h();
  uint32_t start_l = rdcycle_l();
  uint32_t end_h = start_h + time_h + (start_l + time_l >= 0x1'0000'0000 ? 1 : 0);
  uint32_t end_l = start_l + time_l;
  uint32_t current_h = 0;
  uint32_t current_l = 0;
  while(end_h >= current_h && end_l > current_l) {
    current_h = rdcycle_h();
    current_l = rdcycle_l();
  }
}

/// @brief Delay micro seconds (Max = 2^32 us ~ 1.19 hour)
/// @param time = 1 us
void delay_us(uint32_t time_us) {
  uint32_t start = rdcycle(4);
  uint32_t current = 0;
  while(start + time_us > current) {
    current = rdcycle(4);
  }
}

/// @brief Delay mili seconds (Max = 2^32 us ~ 1.19 hour)
/// @param time = 1 us
void delay_ms(uint32_t time_ms) {
  delay_us(time_ms * 1000);
}
