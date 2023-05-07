#!/bin/bash
#$1 - Path to raw image
qemu-system-x86_64 -accel kvm -m 2048 -boot c -hda $1 -vga virtio -spice port=5900,addr=0.0.0.0,disable-ticketing=on -bios /usr/share/qemu/OVMF.fd -cpu host -net nic -net tap,script=no,downscript=no
