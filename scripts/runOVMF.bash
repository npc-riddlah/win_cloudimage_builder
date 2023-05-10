#!/bin/bash
#$1 - Path to raw image
	qemu-system-x86_64 -accel kvm -m 1024 -hda $1 -boot d -vga virtio -bios /usr/share/qemu/OVMF.fd -display none
exit 0

