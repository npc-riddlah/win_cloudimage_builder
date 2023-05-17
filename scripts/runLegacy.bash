#!/bin/bash
#$1 - Path to raw image
#$2 - SPICE Port
#$3 - SPICE Enabled flag

if [ "$3" = true ]; then
	qemu-system-x86_64 -accel kvm -m 2048 -hda $1 -vga virtio -spice port=$2,addr=0.0.0.0,disable-ticketing=on -serial stdio
else
	qemu-system-x86_64 -accel kvm -m 2048 -hda $1 -vga virtio -display none -serial stdio
fi
exit 0
