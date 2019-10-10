bits 16

_read_kernel_error_message: db "[!] Error reading kernel", 0x0d, 0x0a, 0
_read_kernel_disk_address_packet:
  db 0x10
  db 0
  ; Number of sectors to load:
  dw 127
  ; Destination address:
  dw kernel_start_address
  ; Destination segment:
  dw 0
  ; Sector read offset. Skip the first sector of the disk, which is just the
  ; bootloader:
  dq 1

; Requires that `dl` is set to the boot disk number.
read_kernel:
  pusha
  mov si, _read_kernel_disk_address_packet
  mov ah, 0x42
  int 0x13
  jnc _read_kernel_end
  mov si, _read_kernel_error_message
  call bios_print
  jmp fatal_error
_read_kernel_end:
  popa
  ret
