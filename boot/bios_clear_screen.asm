bios_clear_screen:
  pusha
  mov ah, 0xf
  int 0x10
  mov ah, 0
  int 0x10
  popa
  ret
