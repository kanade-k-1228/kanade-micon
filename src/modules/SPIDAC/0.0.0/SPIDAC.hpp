#pragma once
#include <stdint.h>

class SPIDAC {
  volatile uint32_t* reg;
  static const uint16_t BUFF = 0b01000000'00000000;
  static const uint16_t GAIN = 0b00100000'00000000;
  static const uint16_t SHDN = 0b00010000'00000000;
public:
  SPIDAC(volatile uint32_t* addr) : reg(addr) {}
  /// @brief
  /// @param value Analog output value (0...65535) (Upper 12/10/8 bit is used)
  /// @param buf VREF Input Buffer Control bit (1 = Buffered, 0 = Unbuffered)
  /// @param ga Output Gain Selection bit (1 = 1x, 0 = 2x)
  /// @param shdn Output Shutdown Control bit(1 = Active mode operation, 0 = Shutdown the device)
  /// @return
  void analog(uint16_t value, int buf = 1, int ga = 1, int shdn = 1) {
    reg[0] = ((buf ? BUFF : 0) | (ga ? GAIN : 0) | (shdn ? SHDN : 0) | (value >> 4 & 0xFFF));
  }
};
