CC = gcc
CCFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
	-nostartfiles -nodefaultlibs -fno-pic -Wall -Wextra -Werror
LD = ld
LDFLAGS = --Ttext 0x7e00 -m elf_i386 -s --oformat binary -e kmain

all: make_build_dir build/boot.bin build/main.bin
	cat build/boot.bin build/main.bin /dev/zero | head -c 65536 > build/os.img

make_build_dir:
	mkdir -p build

build/boot.bin: boot/boot.asm
	cd boot && nasm -f bin boot.asm -o ../build/boot.bin

build/main.bin: build/main.o
	$(LD) $(LDFLAGS) $< -o $@

build/main.o: kernel/main.c
	$(CC) $(CCFLAGS) -c $< -o $@

run: all
	qemu-system-i386 -drive format=raw,file=build/os.img

clean:
	rm -rf build

.PHONY: all make_build_dir clean
