bits 16

; Using the BIOS, prints the nul-terminated string pointed to by `si`.
bios_print:
  pusha
.top:
  lodsb
  or al, al
  jz .end
  mov ah, 0x0e
  int 0x10
  jmp .top
.end:
  popa
  ret
