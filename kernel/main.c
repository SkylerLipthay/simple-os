#include "va_list.h"

#define VGA_TEXT_BUFFER ((unsigned short*)0xb8000)

void clear_screen();
void kprintf(const char* str, ...);

void kmain() {
  int x = 0;
  clear_screen();
  kprintf("Hello %crom the %s!\n", 'f', "kernel");
  kprintf("Entry point: %x\nStack pointer: %x\n", kmain, &x);
  while (1) { }
}

void placech(unsigned char c, int x, int y, int attr) {
  *(VGA_TEXT_BUFFER + (y * 80 + x)) = (attr << 8) | c;
}

int x = 0;
int y = 0;

void advance_y() {
  x = 0;
  y++;
  if (y >= 25) {
    y = 0;
  }
}

void advance_x() {
  x++;
  if (x >= 80) {
    advance_y();
  }
}

void putch(unsigned char c, int attr) {
  placech(c, x, y, attr);
  advance_x();
}

void clear_screen() {
  x = 0;
  y = 0;

  for (int y = 0; y < 25; y++) {
    for (int x = 0; x < 80; x++) {
      placech(' ', x, y, 0x07);
    }
  }
}

void print_hex(unsigned long val, int attr) {
  int mask = 0xf0000000;
  int shift = 28;
  int seen_non_zero = 0;
  unsigned char digit;

  while (shift >= 0) {
    digit = ((val & mask) >> shift) & 0xf;
    shift -= 4;
    mask >>= 4;
    if (digit == 0 && !seen_non_zero) {
      continue;
    }
    seen_non_zero = 1;
    putch(digit < 10 ? digit + '0' : digit + 87, attr);
  }

  if (!seen_non_zero) {
    putch('0', attr);
  }
}

void kprintf(const char* str, ...) {
  char c;
  char* s;
  int in_sub = 0;
  va_list args;

  va_start(args, str);

  while ((c = *str++) != 0) {
    if (in_sub) {
      in_sub = 0;
      switch (c) {
        case 's':
          s = (char*)va_arg(args, char*);
          while (*s) {
              putch(*s++, 0x07);
          }
          break;

        case 'c':
          putch((char)va_arg(args, int), 0x07);
          break;

        case 'x':
          print_hex((unsigned long)va_arg(args, unsigned long), 0x07);
          break;

        case '%':
          putch('%', 0x07);
          break;
      }
    } else if (c == '%') {
      in_sub = 1;
    } else if (c == '\n') {
      advance_y();
    } else {
      putch(c, 0x07);
    }
  }

  va_end(args);
}
