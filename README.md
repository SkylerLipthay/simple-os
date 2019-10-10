# simple-os

I'm learning about OS development and this is my testbed!

Right now I have a small bootloader that reads up to 64 KB of kernel binary from the boot disk into low memory, enables A20, switches from real mode (16-bit) into protected mode (32-bit), sets up the stack, and jumps straight into the kernel (`kmain`). The build process depends on `nasm`, `ld`, `gcc`, and QEMU (`qemu-system-i386`). Install those and run `make run`. You'll end up with this:

```
Hello from the kernel!
Entry point: 7e00
Stack pointer: efffec
```

Lots of steps in the process are fragile. Currently, certain [areas of memory](https://wiki.osdev.org/Memory_Map_(x86)) are assumed to be free instead of using BIOS INT 15h for memory mapping. There is also no process of [cross-compiling](https://wiki.osdev.org/GCC_Cross-Compiler). Right now I'm just passing in a ton of flags to `gcc` and praying it spits out an agnostic x86 object. We're also depending on `kmain` physically being the very first chunk of code in the kernel.

I find writing a bootloader fairly educational so I might keep at that, or I might just use GRUB. Regardless I'll definitely making the kernel loading process rigorous in general. I want to experiment with paging, virtual memory, multi-processing, and eventually I want to get to GUI programming.
