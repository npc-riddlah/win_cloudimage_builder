#!/bin/bash
PORT_SPICE=5904
PATH_IMG=./result/win22stru_game.raw				 #Selecting output image path
PATH_MNT=/mnt/win2022stru_game				 #Selecting PATH where we mount all images (ISO, RAW)
PATH_ISO=./ISO/win22ru.iso				 #Path to windows installation disk ISO
PATH_PE=./scripts/resources/winpe/				 #Path to prepared earlier WinPE overlay. You can check all changes in ./resources/winpe at example
PATH_ELEMENT=./elements/win2022_st_ru_base/		 #Path to first element. You can add more than one. Element - the collection of settings that will be applied to image.
PATH_UNATTENDXML=./elements/win2022_st_ru_base/Unattend.xml #Path to Unattend.xml file to skip OOBE and set the first configuration on boot
PATH_RUNNER=./scripts/runOVMF.bash			 #Path to runner. Runner - script, that will run final VM to prepare drivers, updates and elements.
VAR_NAME=Windows\ Server\ 2022\ SERVERSTANDARD		 #Name of Windows edition in WIM file
VAR_SIZE=21G						 #Final size of the image.

./scripts/createImage.bash -i $PATH_IMG -m $PATH_MNT -s $VAR_SIZE -S 50G -I $PATH_ISO -w $PATH_PE -n "$VAR_NAME" -u $PATH_UNATTENDXML -r $PATH_RUNNER -e $PATH_ELEMENT -e ./elements/cloudbase-init/ -p $PORT_SPICE -e ./elements/gameready -e ./elements/virtio -e ./elements/baremetaldrv
exit 0
