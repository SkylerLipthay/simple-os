bits 16

; Using the BIOS, prints the nul-terminated string pointed to by `si`.
bios_print:
  pusha
_bios_print_loop:
  lodsb
  or al, al
  jz _bios_print_end
  mov ah, 0x0e
  int 0x10
  jmp _bios_print_loop
_bios_print_end:
  popa
  ret
