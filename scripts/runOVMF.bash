#!/bin/bash
#$1 - Path to raw image
#$2 - SPICE Port
qemu-system-x86_64 -accel kvm -m 2048 -boot c -hda $1 -vga virtio -spice port=$2,addr=0.0.0.0,disable-ticketing=on -bios /usr/share/qemu/OVMF.fd -smp cores=4 -cpu Skylake-Client-v3
exit 0
