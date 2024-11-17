#include "UART.hpp"
#include "cpu.hpp"

uint32_t char_to_int(char c);

// --------------------------------------------------------------------------------
// Settings

void UART::baud(uint32_t baudrate) {
  reg[0] = CLK_HZ / baudrate;
}

// --------------------------------------------------------------------------------
// Send

UART& UART::print(char c) {
  reg[Reg_IO] = c;
  return *this;
}

UART& UART::print(const char* str) {
  while(*str != '\0') print(*(str++));
  return *this;
}

UART& UART::hex(uint32_t num, int digits) {
  for(int i = (4 * digits) - 4; i >= 0; i -= 4)
    print("0123456789ABCDEF"[(num >> i) & 0xF]);
  return *this;
}

UART& UART::dec(uint32_t num) {
  char buffer[10];
  char* ptr = buffer;
  while(num || ptr == buffer) {
    *(ptr++) = num % 10;
    num = num / 10;
  }
  while(ptr != buffer) {
    print('0' + *(--ptr));
  }
  return *this;
}

// --------------------------------------------------------------------------------
// Receive

uint32_t UART::receive() {
  int32_t received = -1;
  uint32_t start = rdcycle_l();
  for(;;) {
    received = reg[Reg_IO];
    if(received != -1) break;
  }
  return received;
}

// Timeout (us)
uint32_t UART::receive(uint32_t timeout) {
  int32_t received = -1;
  uint32_t start = rdcycle(4);
  for(;;) {
    if(rdcycle(4) > timeout + start) break;
    received = reg[Reg_IO];
    if(received != -1) break;
  }
  return received;
}

uint32_t UART::receive_int() {
  uint32_t ret = 0;
  char rcv;
  while(true) {
    rcv = receive();
    if('0' <= rcv && rcv <= '9') {
      ret += ret * 10 + (rcv - '0');
    } else {
      break;
    }
  }
  return ret;
}

uint32_t char_to_int(char c) {
  if('0' <= c && c <= '9')
    return c - '0';
  else if('A' <= c && c <= 'F')
    return c - 'A' + 10;
  else if('a' <= c && c <= 'f')
    return c - 'a' + 10;
  else
    return -1;
}
