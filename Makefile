.PHONY: all run clean
.DEFAULT: all

ASM_SOURCES = $(wildcard boot/*.asm)
C_SOURCES = $(wildcard kernel/*.c drivers/*.c)
HEADERS = $(wildcard kernel/*.h drivers/*.h)
BINARIES = $(shell find . -path "*.bin")
OBJECTS = $(shell find . -path "*.o")
OBJ = ${C_SOURCES:.c=.o}
CC = gcc
CFLAGS = -std=c11 -m32 -ffreestanding -c

all: os-image

run: os-image
	qemu-system-x86_64 -drive format=raw,file=os-image

os-image: boot/boot_sector.bin kernel/kernel.bin
	rm -f $@
	cat $^ > os-image
	dd if=/dev/zero bs=1 count=15360 >> os-image

boot/boot_sector.bin: ${ASM_SOURCES}
	nasm $< -f bin -o $@

kernel/kernel.bin: kernel/kernel_entry.o ${OBJ}
	ld -melf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

kernel/kernel_entry.o: kernel/kernel_entry.asm
	nasm $< -f elf32 -o $@

%.o: %.c ${HEADERS}
	$(CC) $(CFLAGS) -I. $< -o $@

clean:
	rm -f os-image ${OBJECTS} ${BINARIES}
