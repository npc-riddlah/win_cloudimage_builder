#!/bin/bash
PATH_IMG=./result/test.raw
PATH_MNT=/mnt/win
PATH_ISO=/media/data0/ISO/win22ru.iso
PATH_PE=/media/data0/ISO/WinPE_amd64.iso
PATH_ELEMENT=./elements/win2022_ru_base/
VAR_NAME=Windows\ Server\ 2022\ SERVERSTANDARD
VAR_SIZE=20G

./scripts/createImage.bash $PATH_IMG $PATH_MNT $VAR_SIZE $PATH_ISO $PATH_PE "$VAR_NAME" $PATH_ELEMENT
