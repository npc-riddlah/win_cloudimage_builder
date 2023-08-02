#!/bin/bash

#Default settings here:
FLAG_RUNNER=false
FLAG_SPICE=false
PATH_WINPE_OVERLAY=./scripts/resources/winpe/
SIZE_IMAGE_INIT=50G
SIZE_IMAGE=25G
SIZE_RESERVE=536870912 #Reserve in bytes that will be used in image shrinking. Size of final filesystem will be lesser than entire image by value.
help_out(){
	printf "%s\n" "Commandline parameters:"
	printf "%s\n" "-h or --help 		: This text"
	printf "%s\n" "-i or --image		: Path of final raw image. Where we store it"
	printf "%s\n" "-m or --mount		: Path of directory, where image will be mounted"
	printf "%s\n" "-s or --size		: Size of the final image (At example: 20G)"
	printf "%s\n" "-S or --sizeinit		: Initial image size. Will be shrinked to --size at the end. 50G by default"
	printf "%s\n" "-I or --iso		: Path to reference Windows ISO image"
	printf "%s\n" "-w or --winpeoverlay	: Path to prepared WinPE Overlay that will applied to the WinPE image"
	printf "%s\n" "-n or --name		: Name of Windows in WIM image (Windows Server 2022 SERVERSTANDARD at example)"
	printf "%s\n" "-u or --unattendxml	: Path to unattend.xml"
	printf "%s\n" "-r or --runner		: Path to VM runner script"
	printf "%s\n" "-p or --spiceport	: Port of qemu SPICE server. When sets turns on SPICE on VM's"
	printf "%s\n" "Runner must run virtual machine somewhere based on input RAW image"
	printf "%s\n" "Example: ./scripts/runOVMF.sh ./result/win22.raw"
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

err_out(){
        if [[ -n "$1" ]]; then
        C_RED='\033[0;31m'
        C_NULL='\033[0m'
        printf "${C_RED}[ERROR] $1 ${C_NULL}\n"
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
	parted "$1" -s -- mkpart primary fat32 1M 106M
	parted "$1" -s -- set 1 esp on
	parted "$1" -s -- set 1 boot on
	parted "$1" -s -- set 1 legacy_boot on
	parted "$1" -s -- mkpart primary ntfs 106M 100%
	parted "$1" -s -- set 2 msftdata on
	mkfs.vfat "$1""p1" -F32
	mkfs.ntfs "$1""p2" -Q -v -F -p 0 -S 1 -H 1 -q
	parted "$1" -s -- print
}

wim_extract(){
	info_out "Extracting WIM archive"
	#wiminfo $1/iso/sources/install.wim "$2"
	wimapply $1/iso/sources/install.wim "$2" $3"p2"
}

copy_unattend(){
	info_out "Copying Unnattend.xml"
	mkdir ${2}/raw/Windows/Panther -p
	cp $1 ${2}/raw/Windows/Panther/Unattend.xml -v
}

copy_mainhook(){
	info_out "Copying Main hook"
	PATH_SCRIPT=$(dirname "${BASH_SOURCE[0]}")
#	mkdir -p ${1}/raw/ProgramData/Microsoft/Windows/Start\ Menu/Programs/Startup
#	cp $PATH_SCRIPT/resources/build/mainhook.cmd ${1}/raw/ProgramData/Microsoft/Windows/Start\ Menu/Programs/Startup/mainhook.cmd -v
	cp $PATH_SCRIPT/resources/build/mainhook.cmd ${1}/raw/ -v
}

copy_element(){
	info_out "Copying element:"$1
	mkdir ${2}/raw/hooks/preinstall -p
	mkdir ${2}/raw/hooks/install -p
	mkdir ${2}/raw/hooks/configure -p
	mkdir ${2}/raw/hooks/clean -p
	cp $1/root/* ${2}/raw/ -vfR
	cp $1/preinstall/*  ${2}/raw/hooks/preinstall/ -vR
	cp $1/install/*  ${2}/raw/hooks/install/ -vR
	cp $1/configure/* $2/raw/hooks/configure/ -vR
	cp $1/clean/* ${2}/raw/hooks/clean/ -vR
}

directories_umount(){
	info_out "Unmounting directiories"
	umount $1/iso
	umount $1/raw
	losetup -d "$2"
}


winpe_create(){
	info_out "Creating WinPE Image"
	mkwinpeimg -i -O $2 -a amd64 -W $3/iso $1
}

run_winpe(){
	info_out "Running WinPE with bootsect installation"
	if [ "$4" = true ]; then
		qemu-system-x86_64 -machine q35,accel=kvm -m 2048 -hda $1 -boot d -cdrom $2 -vga virtio -spice port=$3,addr=0.0.0.0,disable-ticketing=on
	else
		qemu-system-x86_64 -machine q35,accel=kvm -m 2048 -hda $1 -boot d -cdrom $2 -vga virtio -display none
	fi
}

run_win(){
	info_out "Running installed windows. Awaiting finish..."
	info_out "Runner: $1 $2 $3 $4"
	eval "$1 $2 $3 $4"
}

image_shrink(){
#	info_out "Shrinking image"
#	PATH_LO=$(losetup --partscan --show --find $1)
#	ntfsresize -f --size $(expr $2 - $SIZE_RESERVE) ${PATH_LO}p2
#	parted "${PATH_LO}" -s -- resizepart 2 $(expr $2 - $SIZE_RESERVE)
#	parted "${PATH_LO}" -s -- rm 2
#	losetup -d ${PATH_LO}
#	qemu-img resize --shrink $1 $2
#	PATH_LO=$(losetup --partscan --show --find $1)
#	parted "${PATH_LO}" -s -- mkpart primary ntfs 106M 100%
#        parted "${PATH_LO}" -s -- set 2 msftdata on
#	parted "${PATH_LO}" -s -- print
#	losetup -d ${PATH_LO}
}

quit_int(){
	err_out "SIGINT RECEIVED!"
	umount $1/iso
	umount $1/raw
	losetup -d "$2"
	exit 1
}

if [ "$EUID" -ne 0 ]
  then err_out "Please run as root (sudo)"
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
	-S|--sizeinit)
		SIZE_IMAGE_INIT=$2
		shift
		shift
	;;
	-I|--iso)
		PATH_ISO=$2
		shift
		shift
	;;
	-w|--winpeoverlay)
		PATH_WINPE_OVERLAY=$2
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
        -r|--runner)
		FLAG_RUNNER=true
                PATH_RUNNER=$2
                shift
                shift
        ;;
	-p|--spiceport)
		FLAG_SPICE=true
		PORT_SPICE=$2
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

trap "quit_int $PATH_MOUNT ${PATH_LO}" INT

#Running all necessary tasks

#Doing size convertation
SIZE_IMAGE_INIT_MEASURE=${SIZE_IMAGE_INIT: -1}
case $SIZE_IMAGE_INIT_MEASURE in
	"K")
		SIZE_IMAGE_INIT=${SIZE_IMAGE_INIT%K*}
		SIZE_IMAGE_INIT=$(expr ${SIZE_IMAGE_INIT} \* 1024)
	;;
	"M")
		SIZE_IMAGE_INIT=${SIZE_IMAGE_INIT%M*}
		SIZE_IMAGE_INIT=$(expr ${SIZE_IMAGE_INIT} \* 1048576)
	;;
	"G")
		SIZE_IMAGE_INIT=${SIZE_IMAGE_INIT%G*}
		SIZE_IMAGE_INIT=$(expr ${SIZE_IMAGE_INIT} \* 1073741824)
	;;
esac

SIZE_IMAGE_MEASURE=${SIZE_IMAGE: -1}
case $SIZE_IMAGE_MEASURE in
	"K")
		SIZE_IMAGE=${SIZE_IMAGE%K*}
		SIZE_IMAGE=$(expr ${SIZE_IMAGE} \* 1024)
	;;
	"M")
		SIZE_IMAGE=${SIZE_IMAGE%M*}
		SIZE_IMAGE=$(expr ${SIZE_IMAGE} \* 1048576)
	;;
	"G")
		SIZE_IMAGE=${SIZE_IMAGE%G*}
		SIZE_IMAGE=$(expr ${SIZE_IMAGE} \* 1073741824)
	;;
esac

#Building image here
time_start=$SECONDS

iso_mount $PATH_MOUNT $PATH_ISO
image_create $PATH_IMAGE ${SIZE_IMAGE_INIT}
PATH_LO=$(losetup --partscan --show --find $PATH_IMAGE)
image_part ${PATH_LO}
wim_extract $PATH_MOUNT "$NAME_IMAGE" ${PATH_LO}
raw_mount $PATH_MOUNT ${PATH_LO}p2
copy_unattend $PATH_UNATTEND $PATH_MOUNT
copy_mainhook $PATH_MOUNT
for ((i=1; i <= $ELEMENT_COUNT; i++)) do copy_element ${PATH_ELEMENT[$i]} $PATH_MOUNT; done
winpe_create $PATH_IMAGE.winpe $PATH_WINPE_OVERLAY $PATH_MOUNT
directories_umount $PATH_MOUNT ${PATH_LO}
run_winpe $PATH_IMAGE $PATH_IMAGE.winpe $PORT_SPICE $FLAG_SPICE
if [ "$FLAG_RUNNER" = true ]; then
	run_win $PATH_RUNNER $PATH_IMAGE $PORT_SPICE $FLAG_SPICE
fi
image_shrink $PATH_IMAGE ${SIZE_IMAGE}
time_end=$(( SECONDS - time_start ))
info_out "Image is done!"
info_out "Image was builded in: $time_end seconds"
exit 0
