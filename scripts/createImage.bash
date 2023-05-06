#!/bin/bash

help_out(){
	printf "%s\n" "Commandline parameters:"
	printf "%s\n" "-h or --help 	: This text"
	printf "%s\n" "-i or --image	: Path of final raw image. Where we store it"
	printf "%s\n" "-m or --mount	: Path of directory, where image will be mounted"
	printf "%s\n" "-s or --size	: Size of the final image (At example: 20G)"
	printf "%s\n" "-I or --iso	: Path to reference Windows ISO image"
	printf "%s\n" "-w or --winpeiso: Path to prepared WinPE ISO that will create bcd storage"
	printf "%s\n" "-n or --name	: Name of Windows in WIM image (Windows Server 2022 SERVERSTANDARD at example)"
}

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

#Parsing commandline here
POSITIONAL_ARGS=()
(( ELEMENT_COUNT=0 ))
while [[ $# -gt 0 ]]; do
	case $1 in
	-h|--help)
		help_out
		exit 0
		shift
		shift
	;;
	-i|--image)
		PATH_IMAGE=$2
		shift
		shift
	;;
	-m|--mount)
		PATH_MOUNT=$2
		shift
		shift
	;;
	-s|--size)
		SIZE_IMAGE=$2
		shift
		shift
	;;
	-I|--iso)
		PATH_ISO=$2
		shift
		shift
	;;
	-w|--winpeiso)
		PATH_WINPE=$2
		shift
		shift
	;;
	-n|--name)
		NAME_IMAGE="$2"
		shift
		shift
	;;
	-e|--element)
		((ELEMENT_COUNT++))
		PATH_ELEMENT[$ELEMENT_COUNT]=$2
		shift
		shift
	;;
	-*|--*)
		info_out "Unknown option $1"
		help_out
		exit 1
	;;
	*)
		POSITIONAL_ARGS+=("$1")
		shift
	;;
	esac
done

#Running all necessary tasks
directories_mount $PATH_MOUNT $PATH_ISO
image_create $PATH_IMAGE $SIZE_IMAGE
PATH_LO=$(losetup --partscan --show --find $PATH_IMAGE)
image_part ${PATH_LO}
wim_extract $PATH_MOUNT "$NAME_IMAGE" ${PATH_LO}
copy_unattend $PATH_ELEMENT"/Unattend.xml" ${PATH_LO}
for ((i=1; i <= $ELEMENT_COUNT; i++)) do copy_element ${PATH_ELEMENT[$i]} $PATH_MOUNT; done
directories_umount $PATH_ISO ${PATH_LO}
run_winpe $PATH_IMAGE $PATH_WINPE
info_out "All is done!"
exit 0
