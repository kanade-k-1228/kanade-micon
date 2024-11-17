#pragma once
#include "cpu.hpp"
#include <stdint.h>

class UART {
  volatile uint32_t* reg;
  enum Regs { Reg_Baud = 0,
              Reg_IO = 1 };
public:
  UART(volatile uint32_t* addr) : reg(addr) {}

  // Set Baudrate
  void baud(uint32_t baudrate);

  // Print Char
  UART& print(char c);

  // Print String
  UART& print(const char* str);

  // Print integer in hexadecimal
  UART& hex(uint32_t num, int digits);

  // Print integer in decimal
  UART& dec(uint32_t num);

  // Receive synchronous
  uint32_t receive();

  // Receive with timeout (us)
  uint32_t receive(uint32_t timeout);

  // Receive as a integer
  uint32_t receive_int();
};
