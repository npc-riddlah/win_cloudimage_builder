#!/bin/bash
PORT_SPICE=5900
PATH_IMG=./result/win19sten_game.raw				 #Selecting output image path
PATH_MNT=/mnt/win2019sten_game				 #Selecting PATH where we mount all images (ISO, RAW)
PATH_ISO=./ISO/win19en.iso				 #Path to windows installation disk ISO
PATH_PE=./ISO/WinPE_amd64.iso				 #Path to prepared earlier WinPE ISO. You can check all changes in ./resources/winpe
PATH_ELEMENT=./elements/win2019_st_en_base/		 #Path to first element. You can add more than one. Element - the collection of settings that will be applied to image.
PATH_UNATTENDXML=./elements/win202_st_en_base/Unattend.xml #Path to Unattend.xml file to skip OOBE and set the first configuration on boot
PATH_RUNNER=./scripts/runOVMF.bash			 #Path to runner. Runner - script, that will run final VM to prepare drivers, updates and elements.
VAR_NAME=Windows\ Server\ 2019\ SERVERSTANDARD		 #Name of Windows edition in WIM file
VAR_SIZE=20G						 #Final size of the image.

./scripts/createImage.bash -i $PATH_IMG -m $PATH_MNT -s $VAR_SIZE -I $PATH_ISO -w $PATH_PE -n "$VAR_NAME" -e $PATH_ELEMENT -u $PATH_UNATTENDXML -r $PATH_RUNNER -e ./elements/cloudbase-init/ -p $PORT_SPICE -e ./elements/gameready -e ./elements/virtio -e ./elements/baremetaldrv
exit 0
