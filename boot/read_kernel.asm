bits 16

; Requires that `dl` is set to the boot disk number.
read_kernel:
  pusha
  mov si, .disk_address_packet
  ; TODO: Apparently I need to check for the presence of extensions with 0x41
  ; first...
  ;
  ; See: https://github.com/rust-osdev/bootloader/blob/master/src/stage_1.s#L73
  mov ah, 0x42
  int 0x13
  jnc .end
  mov si, .error_message
  call bios_print
  jmp fatal_error
.end:
  popa
  ret

.error_message: db "[!] Error reading kernel", 0x0d, 0x0a, 0
.disk_address_packet:
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
