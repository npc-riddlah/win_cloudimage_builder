#!/bin/bash
#$1 - Path to raw image
#$2 - SPICE Port
#$3 - SPICE Enabled flag

if [ "$3" = true ]; then
#	qemu-system-x86_64 -accel kvm -m 2048 -boot c -hda $1 -vga virtio -serial file:$1.log -spice port=$2,addr=0.0.0.0,disable-ticketing=on -bios /usr/share/qemu/OVMF.fd -smp cores=4 -cpu Skylake-Client-v3
	qemu-system-x86_64 -enable-kvm -machine q35,accel=kvm -m 8128 -boot c -hda $1 -vga virtio -serial stdio -spice port=$2,addr=0.0.0.0,disable-ticketing=on -bios /usr/share/qemu/OVMF.fd -smp cores=8 -cpu host
else
	qemu-system-x86_64 -enable-kvm -machine q35,accel=kvm -m 8128 -boot c -hda $1 -vga virtio -serial file:$1.log -bios /usr/share/qemu/OVMF.fd -smp cores=8 -cpu host
fi
exit 0

