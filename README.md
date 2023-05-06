Tool to build Windows images on Linux hosts

Commandline parameters:
-h or --help    : This text
-i or --image   : Path of final raw image. Where we store it
-m or --mount   : Path of directory, where image will be mounted
-s or --size    : Size of the final image (At example: 20G)
-I or --iso     : Path to reference Windows ISO image
-w or --winpeiso: Path to prepared WinPE ISO that will create bcd storage
-n or --name    : Name of Windows in WIM image (Windows Server 2022 SERVERSTANDARD at example)
