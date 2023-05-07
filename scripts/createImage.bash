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
	printf "%s\n" "-u or --unattendxml    : Path to unattend.xml"
}

info_out(){
	if [[ -n "$1" ]]; then
	C_GREN='\033[0;32m'
	C_NULL='\033[0m'
	printf "${C_GREN}[INFO] $1 ${C_NULL}\n"
	fi
}

warn_out(){
	if [[ -n "$1" ]]; then
	C_YELW='\033[1;33m'
	C_NULL='\033[0m'
	printf "${C_YELW}[WARN] $1 ${C_NULL}\n"
	fi
}

iso_mount(){
	info_out "Mounting iso"
	mkdir -p $1
	mkdir -p $1/iso
	mount -o loop $2 $1/iso
	ls $1/iso -ahl
}

raw_mount(){
	info_out "Mounting raw image"
	mkdir -p $1
	mkdir -p $1/raw
	mount $2 $1/raw
	ls $1/raw -ahl
}

image_create(){
	info_out "Creating image"
        qemu-img create -f raw -o size=$2 $1
        parted $1 mklabel gpt \$> /dev/null
}


image_part(){
	info_out "Partitioning image"
	parted "$1" -- mkpart primary fat32 1M 106M
	parted "$1" -- set 1 esp on
	parted "$1" -- set 1 boot on
	parted "$1" -- mkpart primary ntfs 106M 100%
	parted "$1" -- set 2 msftdata on
	parted "$1" -- print
	mkfs.vfat "$1""p1" -F32
	mkfs.ntfs "$1""p2" -Q -v -F -p 0 -S 1 -H 1 -q
}

wim_extract(){
	info_out "Extracting WIM archive"
	#wiminfo $1/iso/sources/install.wim "$2"
	wimapply $1/iso/sources/install.wim "$2" $3"p2"
}

copy_unattend(){
	info_out "Copying Unnattend.xml"
	mkdir ${2}/raw/Windows/Panther -p
	cp $1 ${2}/raw/Windows/Panther/Unattend.xml
}

copy_element(){
	info_out "Copying element:"$1
	cp $1/root/* ${2}/raw/ -vR
#	cp $1/autostart/*  ${2}/Windows/Setup/Scripts/ -vR
	cp $1/autostart/*  ${2}/raw/ProgramData/Microsoft/Windows/Start\ Menu/Programs/Startup
}

directories_umount(){
	info_out "Unmounting directiories"
	umount $1/iso
	umount $1/raw
	losetup -d "$2"
}

run_winpe(){
	info_out "Running pe with bootsect installation"
	qemu-system-x86_64 -accel kvm -m 1024 -hda $1 -boot d -cdrom $2 -vga virtio -spice port=5900,addr=0.0.0.0,disable-ticketing=on -bios /usr/share/qemu/OVMF.fd
}

run_win(){
	info_out "Running installed windows. Awaiting sysprep to finish..."
	qemu-system-x86_64 -accel kvm -m 2048 -boot c -hda $1 -vga virtio -spice port=5900,addr=0.0.0.0,disable-ticketing=on -bios /usr/share/qemu/OVMF.fd -cpu host -net nic -net tap,script=no,downscript=no
}

if [ "$EUID" -ne 0 ]
  then warn_out "Please run as root (sudo)"
  exit
fi

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
	-u|--unattendxml)
		PATH_UNATTEND=$2
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
iso_mount $PATH_MOUNT $PATH_ISO
image_create $PATH_IMAGE $SIZE_IMAGE
PATH_LO=$(losetup --partscan --show --find $PATH_IMAGE)
image_part ${PATH_LO}
wim_extract $PATH_MOUNT "$NAME_IMAGE" ${PATH_LO}
raw_mount $PATH_MOUNT ${PATH_LO}p2
copy_unattend $PATH_UNATTEND $PATH_MOUNT
for ((i=1; i <= $ELEMENT_COUNT; i++)) do copy_element ${PATH_ELEMENT[$i]} $PATH_MOUNT; done
directories_umount $PATH_MOUNT ${PATH_LO}
run_winpe $PATH_IMAGE $PATH_WINPE
run_win $PATH_IMAGE
info_out "All is done!"
exit 0
