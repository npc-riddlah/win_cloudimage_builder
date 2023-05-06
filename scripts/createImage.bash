#!/bin/bash
#$1 - path of .raw file
#$2 - path of mount dir
#$3 - size of image
#$4 - path of iso file
#$5 - path to WinPE prepared ISO
#$6 - Image Name ("Windows Server 2019 SERVERSTANDARD" at example)
#$7 - Path to element with scripts

PATH_IMAGE=$1
PATH_MOUNT=$2
PATH_ISO=$4
PATH_WINPE=$5
SIZE_IMAGE=$3
NAME_IMAGE=$6
PATH_ELEMENT=$7

info_out(){
	C_GREN='\033[0;32m'
	C_NULL='\033[0m'
	printf "${C_GREN}[INFO] $1 ${C_NULL}\n"
}

directories_mount(){
	info_out "Mounting dirs"
	mkdir $1
	mkdir $1/iso
	mount -o loop $2 $1/iso
}

image_create(){
	info_out "Creating image"
        qemu-img create -f raw -o size=$2 $1
        parted $1 mklabel gpt
}


image_part(){
	info_out "Partitioning image"
	parted "$1" -- mkpart primary fat32 1M 512M
	parted "$1" -- set 1 esp on
	parted "$1" -- set 1 boot on
	parted "$1" -- mkpart primary ntfs 512M 100%
	parted "$1" -- set 2 esp on
	parted "$1" -- set 2 boot on
	mkfs.vfat "$1""p1" -F32
	mkfs.ntfs "$1""p2" -Q -v -F -p 0 -S 1 -H 1
#	ms-sys -n "$1""p2"
#	install-mbr -i n -p D -t 0 "$1"
#	lilo -b $1 mbr
}

wim_extract(){
	info_out "Extracting WIM archive"
	wiminfo $1/iso/sources/install.wim
	echo "wimapply "$1"/iso/sources/install.wim" "$2" $3"p2"
	wimapply $1/iso/sources/install.wim "$2" $3"p2"
}

copy_unattend(){
	info_out "Copying Unnatend.xml"
	mkdir ${2}p2/Windows/Panther
	cp $1 ${2}p2/Windows/Panther/Unnatend.xml
}

copy_element(){
	info_out "Copying element:"$1
	cp $1/root/ ${2}p2/ -vR
	cp $1/autostart/*  ${2}p2/Windows/Setup/Scripts/ -vR
}

directories_umount(){
	info_out "Unmounting directiories"
	umount $1
	losetup -d "$2"
}

run_winpe(){
	info_out "Running pe with bootsect installation"
	qemu-system-x86_64 -accel kvm -m 2048 -drive file=$1,format=raw,index=1,media=disk -boot d -cdrom $2 -vga qxl -spice port=5900,addr=0.0.0.0,disable-ticketing=on -bios /usr/share/qemu/OVMF.fd
}

directories_mount $PATH_MOUNT $PATH_ISO
image_create $PATH_IMAGE $SIZE_IMAGE
PATH_LO=$(losetup --partscan --show --find $1)
image_part ${PATH_LO}
wim_extract $PATH_MOUNT "$NAME_IMAGE" ${PATH_LO}
copy_unattend $PATH_ELEMENT"/Unattend.xml" ${PATH_LO}
copy_element $PATH_ELEMENT $PATH_MOUNT
directories_umount $PATH_ISO ${PATH_LO}
run_winpe $PATH_IMAGE $PATH_WINPE
info_out "All is done!"
exit 0

#mkdir $2
#mkdir $2/iso

#mount -o loop $4 $2/iso

#qemu-img create -f raw -o size=$3 $1
#parted $1 mklabel msdos
#PATH_LO=$(losetup --partscan --show --find $1)

#parted "${PATH_LO}" -- mkpart primary fat32 1M 512M
#parted "${PATH_LO}" -- set 1 esp on
#parted "${PATH_LO}" -- set 1 boot on
#parted "${PATH_LO}" -- mkpart primary ntfs 512M 100%
#parted "${PATH_LO}" -- set 2 esp on
#parted "${PATH_LO}" -- set 2 boot on
#mkfs.vfat "${PATH_LO}""p1" -F32
#mkfs.ntfs "${PATH_LO}""p2" -Q -v -F -p 0 -S 1 -H 1
#ms-sys -n "${PATH_LO}""p2"
#install-mbr -i n -p D -t 0 "${PATH_LO}"

#wiminfo $2/iso/sources/install.wim
#echo "wimapply "$2"/iso/sources/install.wim" $6 "${PATH_LO}""p2"
#wimapply $2/iso/sources/install.wim "$6" "${PATH_LO}""p2"

#mkdir ${PATH_LO}p2/Windows/Panther
#cp $7 ${PATH_LO}p2/Windows/Panther/Unnatend.xml

#umount $4

#losetup -d "${PATH_LO}"

#echo "Running pe with bootsect installation"
#qemu-system-x86_64 -accel kvm -m 2048 -drive file=$1,format=raw,index=1,media=disk -boot d -cdrom $5 -vga qxl -spice port=5900,addr=0.0.0.0,disable-ticketing=on -bios /usr/share/qemu/OVMF.fd
#echo "All is done!"
#exit 0
