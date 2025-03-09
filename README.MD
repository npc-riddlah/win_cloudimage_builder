# Win-Cloudimage-Builder

Win-Cloudimage-Builder is a small toolkit for quick and automated building of Windows cloud images on Linux operating systems.  
It is provides DIB-like build system based on Elements and image configs, but uses pure windows ISO to build.  
The project is not system-safe at this stage, as it uses insecure functions and paths, such as working with libvirt and system paths and direct 'prerun' prerun scripts calls.   Therefore, we recommend running it in virtual machines with KVM support or in containers.  
Currently, the project is in the early stages of development, and various aspects and features may change in the future. However, it is already ready for use.  

In addition to the build scripts, the repository also includes ready-made examples of elements and images.  
Any feedback is welcome: suggestions, bug reports, pull requests, and feature requests. Please leave them in the Issues section, and we will definitely see them.  

Below are the main principles of operation.  

### 1. Concept and Structure

Win-cloudimage-builder allows for the automatic creation of Windows cloud images on Linux hosts using Qemu/KVM and Libvirt.  
The foundation consists of:  
1. A base Windows ISO image  
2. Elements using PowerShell  
3. Image description in the form of a config  
4. Scripts for launching and automating the build process.  

### 2. Creating Your Own Image

When starting from scratch, you need to:  
1. Upload the ISO image to the `/ISO` folder  
2. Add the necessary elements to `/elements`  
3. Draft a config for the image based on the template:  
```ini
[SETTINGS]
	# Full name of the image. Used when uploading to OpenStack. %date is the only available variable for now.
osName=Windows Server 2025 Standard RU ($date) - GameReady Driver
    # Short name without spaces and special characters prohibited in the file system. Will be used as the unique name for the final file and mount point.
name=win25stru_game
	# Build module. If you plan to use it in one mode always, it's better to specify it in scripts/winbuilder.conf.
builder=virt_win
	# Upload module. Also better to specify in scripts/winbuilder.conf in the [DEFAULTS] section if you don't plan to change it often.
uploader=glance
    # Path where the image file will be saved.
pathSave=/opt/client-resources
    # Path to the original Windows ISO image.
pathIso=./ISO/win25ru.iso
    # Optional: Path to Unnatend.xml which will be used to start Audit Mode during the first build run.
pathUnattend=./elements/windows_general/unnatend/2025.xml
	# Optional: Path to the WinPE overlay, which will be deployed on top of the clean WinPE image.
        #             Planned to be removed and the overlay will be generated automatically based on partition parameters.
pathWinPE=./scripts/resources/winpe
	# Name of the Windows edition as specified in the WIM archive.
editionName=Windows Server 2025 SERVERSTANDARD
    # Image size used during the build stage.
buildSize=50G
    # Optional: If specified, Spice will work on the specified port during the build.
spicePort=5920
	# Optional: We can specify additional parameters for QEMU during the WinPE stage. Useful for WinServer 2025.
winPeQemuCmdline=-cpu Skylake-Client-v3
	# Optional: Build timeout in seconds. Useful if there's a chance of the installation of a package or OS hanging. If not specified, the timeout in winbuilder.conf is used, or 30000 seconds by default.
buildTimeout=20000
    # List of elements to install as paths.
[ELEMENTS] 
./elements/general.d/windows_general
./elements/general.d/cloudbase-init
./elements/general.d/nv-gameready
./elements/general.d/virtio
./elements/general.d/geforceexp
./elements/general.d/baremetaldrv
./elements/general.d/non-existing

    # Optional: Export environment variables to the build environment.
[EXPORTS]
TESTVAR=123

    # Partition parameters. You can specify any number, but:
    #1. buildSize only applies to the size of the last partition during the build stage.
    #   Other partitions will not change their size. Later, we will fix this to resize the specified system partition.
    #2. After the dot, specify the name. In this example, two partitions will be created with the names BOOT and SYSTEM.
[PARTITION.BOOT]
size=100M
filesystem=fat32
# Full list of flags is available at: https://github.com/dcantrell/pyparted/blob/main/src/parted/__init__.py#L159
flags=PARTITION_MSFT_RESERVED;PARTITION_BOOT

[PARTITION.SYSTEM]
size=25500M
filesystem=ntfs
	# The system parameter below indicates which partition Windows will be installed on.
system=true
```
4. Run <Username>-openrc.sh from OpenStack to make automatic upload in Glance available.
5. Run the ```./scripts/buildImage.py ./path/to/windows.config``` script with the image config specified. The build has started.  
6. Through SPICE clients, you can connect to the port specified in spicePort. Catch incorrect behavior, debug elements.  
7. The image is built and uploaded. You can test it on servers.  

### 3. Quick Build from Ready-made Configs

All ready-made image configs are located in the `/images/` directory. You can run them as follows:  
```
cd <repository root>/
sudo ./scripts/buildImage.py ./images/base/2022StandardRu_gameready.conf
```
And optionally, manual upload. The image will be uploaded automatically if the environment variables (openstack.rc) for connecting to OpenStack are specified:  
```
openstack image create --container-format bare --disk-format raw  --file ./result/win10.raw --private --property hw_disk_bus=virtio --property hw_rescue_device=disk --property hw_rescue_bus=virtio --property hw_firmware_type=uefi --progress "Windows 10 RU (May 2024) - GameReady Driver"
```

### 4. Developing Elements

An element is a unit of change. It is a directory with the necessary scripts and programs. When an element is specified, its contents are copied to the image and executed on the virtual machine side. Scripts are written in PowerShell or CMD. PS is preferred.  

The basic structure of an element, in order of execution:  
```
/elements/<element name>/prerun <-- Execution of scripts before the machine starts.
/elements/<element name>/configure <-- Pre-configuration.
/elements/<element name>/install <-- Installation of programs.
/elements/<element name>/clean <-- Cleanup stage before sysprep.
/elements/<element name>/root <-- Copied entirely to the root of the C:/ drive.  
/elements/<element name>/version.txt <-- Package version and optionally name. If absent, the version will be 'none'.
```

PS scripts are placed in the directories to perform actions for configuring and installing programs and the OS.  

The `/elements/<element name>/root` directory should contain various executable files or files to be placed on the C:/ drive. For example, `/elements/<element name>/root/testfolder/testfile.txt` on the host will appear as `C:/testfolder/testfile.txt`.  

In the prerun directory, you can add bash scripts that will be executed after mounting the system FS and before copying the elements. This can be useful for downloading program and driver distributions before starting the machine, updating version.txt, or other actions.  
The following variables are available for prerun scripts:  
```
$WCB_PATH_SYSPART - Path to the mount point of the system partition of the image (the Windows drive, simply put).
$WCB_PATH_ELEMENT - Path in the system to the element.
$WCB_PATH_ISO - Path to the mount point of the original Windows ISO image.
```

The following child functions are available for elements with examples:  
Output timestamp + stdout + serial to log:  
```
logInfo "Installing GameReady Driver"
```
Check if a reboot is needed and reboot if necessary:  
```
checkReboot
```

Install drivers from a directory recursively. In the example, all .inf and .cat files containing "2022" in the full path will be installed:  
```
installDrivers -path_drv "C:/my/drivers/folder" -filter "*2022*"
```

### 5. Modularity:

Build algorithm modules are available in `./scripts/builders`  
Image upload modules are available in `./scripts/uploaders`  
Integration modules are available in `./scripts/integrations`
