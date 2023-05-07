Tool to build Windows images on Linux hosts  

Catalog structure:  
-elements				<- Folder with elements  
---CUSTOM_ELEMENT_NAME	<- One element folder  
-----autostart 			<- Files from here will be copied into shell:startup  
-----root				<- Files from here will be copied in system drive with overwrite  
-ISO					<- Contains ISO with WinPE and other windows original ISO  
-result					<- Contains builded ready to upload .raw images  
-scripts				<- Containst build/run scripts of this tool  
---resources			<- Contains resources for third-party tasks as WinPE image prepare  

Commandline parameters:  
-h or --help    : This text  
-i or --image   : Path of final raw image. Where we store it  
-m or --mount   : Path of directory, where image will be mounted  
-s or --size    : Size of the final image (At example: 20G)  
-I or --iso     : Path to reference Windows ISO image  
-w or --winpeiso: Path to prepared WinPE ISO that will create bcd storage  
-n or --name    : Name of Windows in WIM image (Windows Server 2022 SERVERSTANDARD at example)  
-u or --unattendxml    : Path to unattend.xml  
