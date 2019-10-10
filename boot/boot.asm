bits 16
org 0x7c00

jmp 0:start

start:
  xor ax, ax
  mov es, ax
  mov ds, ax
  mov ss, ax
  ; The bootloader's stack goes from 0x700 down to 0x500 (512 bytes, more than
  ; enough).
  mov sp, 0x700
  call bios_clear_screen
  mov si, .bootloader_entered_message
  call bios_print
  call enable_a20
  mov si, .a20_enabled_message
  call bios_print
  ; BIOS fills `dl` with disk number, which remains untouched here.
  call read_kernel
  mov si, .kernel_read_message
  call bios_print
  jmp switch_to_protected

.bootloader_entered_message: db "[", 0x01, "] Bootloader entered", 0x0d, 0x0a, 0
.a20_enabled_message: db "[", 0x01, "] A20 enabled", 0x0d, 0x0a, 0
.kernel_read_message: db "[", 0x01, "] Kernel read from disk", 0x0d, 0x0a, 0

%include "bios_clear_screen.asm"
%include "bios_print.asm"
%include "enable_a20.asm"
%include "gdt.asm"
%include "fatal_error.asm"
%include "read_kernel.asm"

switch_to_protected:
  ; Disable interrupts until we set up the protected mode interrupt vector.
  cli
  lgdt [gdt_descriptor]
  mov eax, cr0
  or eax, 0x1
  mov cr0, eax
  ; This far jump serves two purposes. Firstly, it sets `cs` to our new GDT's
  ; code segment index. Secondly, and more cryptically, this long jump forces
  ; the CPU to invalidate its pipelining and branch prediction processes. We
  ; usually don't have to worry about this sort of thing, but when switching
  ; modes we have to hint to the CPU not to run other pipelined instructions in
  ; the wrong mode.
  jmp gdt_code_seg:.protected

bits 32

.protected:
  mov ax, gdt_data_seg
  mov ds, ax
  mov es, ax
  mov fs, ax
  mov gs, ax
  mov ss, ax
  mov ebp, kernel_stack_pointer
  mov esp, ebp
  jmp kernel_start_address

kernel_start_address: equ 0x7e00
; Instead of using BIOS interrupt 0x15 to get a map of upper memory (i.e. memory
; above 1 MB), we're just going to use the magic numbers and hope nothing goes
; wrong!
;
; The location of the stack:
kernel_stack_pointer: equ 0x00EFFFFC

times 510 - ($ - $$) db 0
db 0x55
db 0xaa
