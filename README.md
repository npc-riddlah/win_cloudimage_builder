# Win Image Builder 

## Tool to build cloud Windows images.

 

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
