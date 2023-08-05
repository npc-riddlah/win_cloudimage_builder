# Win Image Builder 

### Tool to build cloud Windows images on Linux. 
### Bash-written Alternative to windows-imaging-tools

I tried to make this scripts similiar to diskimage-builder tool in using, but for work with Windows images.
This scripts uses vanilla Windows ISO images, installs it, applies elements running in qemu-kvm and build .raw image at the end.
At the moment this scripts too strange in the some moments, but still usable. 
I recommend use Ubuntu with that (Just don't tested in the other distros) 

How to build image:
1. Clone repository 
2. Place ISO image at the ./ISO directory
3. cd to root of repository
4. sudo ./scripts/createImage.bash -I ./ISO/<your_iso_file_name> -n <win_edition_name> -i <path_to_final_image> -u <path_to_unattend.xml> -m /mnt/<random_mount_name> -e <path_to_element> -r ./scripts/runOVMF.bash -s 25G
5. Wait... And done!

In this list we see:
<your_iso_file_name> - Filename of your .iso image
<win_edition_name> - Name of Windows edition as in WIM image. At example: "Windows Server 2022 SERVERDATACENTER" or "Windows Server 2022 SERVERSTANDARD". You can see the full list of namings by wim-info tool.
<path_to_final_image> - Path where final image and log will be stored. I recommend to create subcatalogue for that.
<path_to_unattend.xml> - Path to unattend.xml file. This file Windows use for initial settings. You can grab one from ./elements/win*_base/unattend.xml. Just change the activation key to what you want. Also, he is compatible with windows from 2012 up to 2022.
<random_mount_name> - just folder where all mountpoints will be created to work with that image. Please, use different mount paths for different images in order to avoid path collisions.
<path_to_element> - In the bottom of this readme you will see catalog structure and order of element execution. You can create elements everywhere to be honest. Here you can specify path to element. There can be several elements.

And, there is ready for launch example of clean, preconfigured and updated Windows Server 2022 Standard cloud image build:
./scripts/createImage.bash -i ./result/win22sten/ -m /mnt/win22sten/ -s 20G -S 50G -I ./ISO/win22en.iso -n "Windows Server 2022 SERVERSTANDARD" -u ./elements/win2022_st_ru_base/Unattend.xml -r ./scripts/runOVMF.bash -e ./elements/win2022_st_ru_base/ -e ./elements/cloudbase-init/ 

Jobs order in details:
1. Mounting specified ISO
2. Creating and partitioning RAW Image
3. Applying WIM archive from specified edition of Windows to RAW image
4. Copying specified elements and main hook which launches elements inside Windows
5. Building WinPE with customizable Bootsector installation script
6. Running this WinPE Image on created RAW image. At this step we getting fully working Windows image, but with big specified size and not installed elements.
7. Running RAW Windows image to install elements online (At the really working Windows instance). You can skip this step ommiting -r option. Or you can use other tools to run Windows.
8. Shrinking image. (Not so good done at this moment, but working)
9. Done. You can upload or run final windows image.

Catalog structure:

    elements/               <- Folder with elements
    ├─ CUSTOM_ELEMENT_NAME/	<- One element folder
    │  ├─ preinstall/       <- Files from here will be copied into C:/hooks/preinstall/ and will be launched by mainhook
    │  ├─ install/          <- Files from here will be copied into C:/hooks/install/ and will be launched by mainhook
    │  ├─ configure/        <- Files from here will be copied into C:/hooks/configure/ and will be launched by mainhook
    │  ├─ clean/            <- Files from here will be copied into C:/hooks/clean/ and will be launched by mainhook
    │  ├─ root/             <- Files from here will be copied in system drive with overwrite
    ISO/                    <- Contains ISO with WinPE and other windows original ISO
    result/                 <- Contains builded ready to upload .raw images
    runbuild/               <- Contains scripts which run image generation
    scripts/                <- Containst build/run scripts of this tool
    ├─ resources/           <- Contains resources for third-party tasks as WinPE image prepare
    │  ├─ build/            <- Contains script needed resources for build
    │  ├─ winpe/            <- Overlay for WinPE images. Used to create boot partition by default

The order of element execution:

0. Mainhook
1. preinstall/*
2. install/*
3. configure/*
4. clean/*

Commandline parameters:

    -h or --help        : This text
    -i or --image       : Path of final raw image. Where we store it
    -m or --mount       : Path of directory, where image will be mounted
    -s or --size        : Size of the final image (At example: 20G)
    -S or --sizeinit    : Initial size of image. Using only on installation proccess. Will be resized to --size at the end.
    -I or --iso         : Path to reference Windows ISO image
    -w or --winpeiso    : Path to prepared WinPE ISO that will create bcd storage
    -n or --name        : Name of Windows in WIM image (Windows Server 2022 SERVERSTANDARD at example)
    -u or --unattendxml : Path to unattend.xml
    -r or --runner      : Path to VM runner script
    -p or --spiceport   : Port of qemu SPICE server. When sets turns on the SPICE on VM's

Runner must run virtual machine somewhere based on RAW image  
Example: ./scripts/runOVMF.sh ./result/win22.raw

You can run image build like that:  
sudo ./build_all_2019_gameready.bash  
sudo ./runbuild/build_2019StandardRu_Gameready.bash  

Similiar tools:  
[Cloudbase Windows-imaging-tools](https://github.com/cloudbase/windows-imaging-tools)  
[OpenStack diskimage-builder](https://github.com/openstack/diskimage-builder)
