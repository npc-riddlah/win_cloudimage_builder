#!/bin/bash
#$1 - Path to raw image
qemu-system-x86_64 -accel kvm -m 2048 -hda $1 -vga virtio -display none
