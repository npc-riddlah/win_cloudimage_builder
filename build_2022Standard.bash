#!/bin/bash
PATH_IMG=./result/test.raw
PATH_MNT=/mnt/win
PATH_ISO=./ISO/win22ru.iso
PATH_PE=./ISO/WinPE_amd64.iso
PATH_ELEMENT=./elements/win2022_ru_base/
VAR_NAME=Windows\ Server\ 2022\ SERVERSTANDARD
VAR_SIZE=20G

./scripts/createImage.bash -i $PATH_IMG -m $PATH_MNT -s $VAR_SIZE -I $PATH_ISO -w $PATH_PE -n "$VAR_NAME" -e $PATH_ELEMENT
