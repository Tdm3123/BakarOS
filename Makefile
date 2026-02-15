AS = nasm
CC = gcc
LD = ld

ASFLAGS = -f elf32
CFLAGS = -m32 -ffreestanding -O2 -Wall -Wextra -fno-pie
LDFLAGS = -m elf_i386 -T linker.ld

KERNEL_BIN = kernel.bin
ISO_DIR = iso
ISO_FILE = myos.iso

all: iso

kernel.bin: kernel/kernel_entry.o kernel/kernel.o
	$(LD) $(LDFLAGS) -o kernel.bin kernel/kernel_entry.o kernel/kernel.o

kernel/kernel_entry.o: kernel/kernel_entry.asm
	$(AS) $(ASFLAGS) kernel/kernel_entry.asm -o kernel/kernel_entry.o

kernel/kernel.o: kernel/kernel.c
	$(CC) $(CFLAGS) -c kernel/kernel.c -o kernel/kernel.o

iso: kernel.bin
	mkdir -p $(ISO_DIR)/boot/grub
	cp kernel.bin $(ISO_DIR)/boot/kernel.bin
	cp boot/grub/grub.cfg $(ISO_DIR)/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO_FILE) $(ISO_DIR)
	@echo "ISO created: $(ISO_FILE)"

run: iso
	qemu-system-i386 -cdrom $(ISO_FILE)

clean:
	rm -f kernel/*.o kernel.bin myos.iso
	rm -rf iso

.PHONY: all clean run iso