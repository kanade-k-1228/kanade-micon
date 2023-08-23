#include "firmware.hpp"
#include "player/rockman_dr_wily.h"

static const int N_CH = 5;

Oscilator* oscs[N_CH] = {
    &square1,
    &square2,
    &square3,
    &sawtooth,
    &triangle};

void sownd_play(int ch, int note) {
  if(0 <= ch && ch < N_CH) oscs[ch]->play(note);
}

void sownd_stop(int ch) {
  if(0 <= ch && ch < N_CH) oscs[ch]->stop();
}

void arpeggio(uint32_t note0, uint32_t note1, uint32_t note2, uint32_t tempo) {
  uint32_t note4 = 1'000'000 * 60 / tempo;  // us
  sownd_play(0, note0);
  delayUs(note4 / 2);
  sownd_play(1, note1);
  delayUs(note4 / 2);
  sownd_play(2, note2);
  delayUs(note4 * 3);

  sownd_stop(0);
  sownd_stop(1);
  sownd_stop(2);
}

void piano() {
  static const char* keys = "zsxdcvgbhnjm,l.;/";
  static const char* keyboard_black = "\e[7m:\e[0m \e[7m \e[0m \e[7m \e[0m\e[7m \e[0m \e[7m \e[0m \e[7m \e[0m \e[7m \e[0m";
  static const char* keyboard_white = "\e[7m:           \e[0m";
  static const char* keyboard_black_key = "\e[7m:\e[0mS\e[7m \e[0mD\e[7m  \e[0mG\e[7m \e[0mH\e[7m \e[0mJ\e[7m \e[0m";
  static const char* keyboard_white_key = "\e[7mZ X CV B N M\e[0m";
  static const char* erase = "\r           :           :           :           :           :           :           :           :           |\r";
  static const char* tab = "           ";
  static const char* ch_name[N_CH] = {"square1", "square2", "square3", "sawtooth", "triangle"};

  const uint32_t OCT_MIN = 1;
  const uint32_t OCT_MAX = 8;

  uint32_t ch = 0;
  uint32_t octave = 3;
  uint32_t notes[N_CH] = {0};

  for(char cmd;;) {

    // Show Keyboard
    serial << tab;
    for(uint32_t i = OCT_MIN; i <= OCT_MAX; ++i) serial << i << (i == octave ? "-----------" : "           ");
    serial << "|" << UART::endl;
    serial << tab;
    for(uint32_t i = OCT_MIN; i <= OCT_MAX; ++i) serial << keyboard_black;
    serial << "|\n";
    serial << tab;
    for(uint32_t i = OCT_MIN; i <= OCT_MAX; ++i) serial << keyboard_white;
    serial << "|\n";
    for(int i = 0; i < N_CH; ++i) {
      serial << erase;
      serial << (i == ch ? "> " : "  ") << ch_name[i] << "\r";
      if(notes[i] != 0) serial << "\e[" << notes[i] - 1 << "C*";
      serial << UART::endl;
    }
    serial << "\e[8F";

    serial >> cmd;
    // Exit
    if(cmd == '\n') break;
    // Change Octave
    if(OCT_MIN <= cmd - '0' && cmd - '0' <= OCT_MAX) octave = cmd - '0';
    // Change Channel
    if(cmd == 'q') ch = 0;
    if(cmd == 'w') ch = 1;
    if(cmd == 'e') ch = 2;
    if(cmd == 'r') ch = 3;
    if(cmd == 't') ch = 4;
    // Stop note
    if(cmd == ' ') {
      sownd_stop(ch);
      notes[ch] = 0;
    }
    // Play sownd
    for(int i = 0; i < 17; ++i) {
      if(cmd == keys[i]) {
        int note = octave * 12 + i;
        notes[ch] = note;
        sownd_play(ch, note);
      }
    }
  }
  sownd_stop(0);
  sownd_stop(1);
  sownd_stop(2);
  sownd_stop(3);
  sownd_stop(4);
  serial << "\n\n\n\n\n\n\n\n";
}

// Compressed MIDI
// Data Format
//          15 - 0:Delay 1:Sound
//   IF Delay
//     14 ~  0 - Delay Time [ms]
//   IF Sound
//     14 ~ 13 - Chip Sellect
//     12 ~ 11 - Channel
//     10 ~  4 - Note Number
//      3 ~  0 - Velocity
void play_cmidi(uint16_t data) {
  int type = data & (0b1 << 15);
  if(type) {
    int channel = (data >> 11) & 0b11;
    int note_number = (data >> 4) & 0b1111'111;
    int velocity = data & 0b1111;
    sownd_play(channel, velocity ? note_number : 0);
  } else {
    delayMs(data);
  }
  return;
}

void play_rockman() {
  serial
      << "  /\\_/\\ \n"
         "6/ '-' )__ \n"
         "(    >____|| o o \n"
         " )  /\\ \\ \n"
         "(__)  \\_> \n";
  for(int i = 0; i < rockman_dr_wily_len; i++) {
    int data = rockman_dr_wily_music[i];
    play_cmidi(data);
  }
}

//////////////////////////////////////////////////////////////////////////////

void init() {
  set_irq_mask(0);
  serial.baud(460800);
  gpio.mode(GPIO::Mode::OUT);

  sampling.set(0x16A);  // 16MHz / 44.1kHz
  square1.set_clk(CLK_FREQ / 2);
  square2.set_clk(CLK_FREQ / 2);
  square3.set_clk(CLK_FREQ / 2);
  sawtooth.set_clk(CLK_FREQ / 256);
  triangle.set_clk(CLK_FREQ / 256 / 2);
  mixier.set_vol(0, 1);
  mixier.set_vol(1, 1);
  mixier.set_vol(2, 1);
  mixier.set_vol(3, 2);
  mixier.set_vol(4, 4);

  serial << "  _  _         _       __  __ ___ ___ ___  _  _  \n"
            " | \\| |_____ _| |_ ___|  \\/  |_ _/ __/ _ \\| \\| | \n"
            " | .` / -_) \\ /  _|___| |\\/| || | (_| (_) | .` | \n"
            " |_|\\_\\___/_\\_\\\\__|   |_|  |_|___\\___\\___/|_|\\_| \n"
            "\n"
            "        32bit RISC-V microcontroller\n"
            "     generated by Next-MICON micon-generator\n"
            "  https://github.com/Next-MICON/micon-generator\n\n";
}

void loop() {
  char cmd;
  while(true) {
    serial << "[a] Blink LED" << UART::endl
           << "[b] Sownd" << UART::endl
           << "[c] Piano" << UART::endl
           << "[d] Play Rockman" << UART::endl;
    serial >> cmd;
    if(cmd == 'a') {
      serial << "=== Blink LED ===" << UART::endl;
      gpio_blink(gpio);
      serial << "=== end ===" << UART::endl;
    }
    if(cmd == 'b') {
      serial << "=== Play Sownd ===" << UART::endl;
      for(int i = 0; i < N_CH; ++i) {
        sownd_play(i, 48);
        delayMs(500);
        sownd_stop(i);
        delayMs(500);
      }
      uint32_t tempo = 120;
      arpeggio(48, 52, 55, tempo);
      arpeggio(53, 57, 60, tempo);
      arpeggio(55, 59, 62, tempo);
      arpeggio(55, 60, 64, tempo);
      serial << "=== end ===" << UART::endl;
    }
    if(cmd == 'c') {
      serial << "=== Piano (exit: \\n) ===" << UART::endl;
      piano();
      serial << UART::endl
             << "=== end ===" << UART::endl;
    }
    if(cmd == 'd') {
      serial << "=== Play Music ===" << UART::endl;
      play_rockman();
      serial << "=== end ===" << UART::endl;
    }
  }
}

uint32_t* irq(uint32_t* regs, uint32_t irqs) {
  static uint32_t irq_counts[32] = {0};
  serial << "\nIRQ:";
  for(uint32_t i = 0; i < 32; ++i) {
    if((irqs & (1 << i)) != 0) {
      ++irq_counts[i];
      serial << " #" << i << "*" << irq_counts[i];
    }
  }
  serial << "\n";
  return regs;
}
