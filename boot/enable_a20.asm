; Before the kernel can access the entire memory range, the bootloader must
; enable the "A20" address line. A20 represents the 21st bit. With just the
; first 20 bits, only the first megabyte (0 to 0xFFFFF) is accessible.
;
; The whole logic of enabling the A20 line is pretty silly. The original Intel
; 8042 keyboard controller had a spare pin on it which routed to the A20 line.
; We continue to use this legacy quirk and communicate with the keyboard using
; I/O ports 0x60 and 0x64.

bits 16

enable_a20:
  pusha
  cli

  call _enable_a20_wait_in
  mov al, 0xad
  out 0x64, al

  call _enable_a20_wait_in
  mov al, 0xd0
  out 0x64, al

  call _enable_a20_wait_out
  in al, 0x60
  push ax

  call _enable_a20_wait_in
  mov al, 0xd1
  out 0x64, al

  call _enable_a20_wait_in
  pop ax
  or al, 2
  out 0x60, al

  call _enable_a20_wait_in
  mov al, 0xae
  out 0x64, al

  call _enable_a20_wait_in
  sti
  popa
  ret

_enable_a20_wait_in:
  in al, 0x64
  test al, 2
  jnz _enable_a20_wait_in
  ret

_enable_a20_wait_out:
  in al, 0x64
  test al, 1
  jz _enable_a20_wait_out
  ret
