from buildImageLib import *
    
class imageRunner(Image):
    def __init__(self, imageconfig):
        super(imageRunner, self).__init__(imageconfig)
        configFile.read(imageconfig)
        for partition in configFile:
            if "PARTITION." in partition:
                logger.debug("Detected partitions in imageconfig. Cleaning default partition table.")
                self.partitionTable = loadPartitions(configFile)
                break
        if not self.partitionTable:
            throwError("Partitioning settings not found! Define it in default config or image config")
        self.partitionTableTarget = deepcopy(self.partitionTable)
        
        #Defining neccessary parameters
        requiredSettingsList = ['osName','name','pathSave','pathIso','editionName','buildSize']
        
        #Checking that necessary variables has been defined
        for setting in requiredSettingsList:
            if setting in dir(self):
                pass
            else:
                throwError(f"Required parameter is not defined: {setting}")
        
    def build(self):
        #Forming start message for external platforms. Todo: Separate to function
        startMessage = f"""🛠*Build started!*🛠  

ID: {self.uuid}  
Name: {self.osName}  
Elements:
```
"""
        for element, version in self.elements.items():
            startMessage+=f"""{element} {version}
"""
        startMessage+="```"
        sendStatus(startMessage)

        #Starting build here. At first configuring logger and creating mountpoint
        logger.info(f"Starting Build. ID: {self.uuid}")
        mountPoint=f"/mnt/winbuild/{self.uuid}"
        os.makedirs(mountPoint, exist_ok=True)
        
        try:
            #The main: Creating and partitioning image, do WIM things, running and shrinking disk.
            checkPartTableConsistency(self.partitionTable)
            imgGptCreate(self.partitionTable, self.fullImgPath, self.buildSize)
            isoMount(mountPoint, self.pathIso)
            extractWIM(mountPoint, self.fullImgPath, self.editionName, self.partitionTable)
            rawMount(mountPoint, self.fullImgPath, self.partitionTable)
            
            for element, version in self.elements.items():
                if os.path.isdir(element):
                    prepareElement(element, mountPoint)
                    copyElement(element, mountPoint)
                    logger.debug(f"Version: {version}")
                else:
                    logger.warning(f"Element specified but not found. Skipping: {element}")
            
            copyUnattend(self.pathUnattend, mountPoint)
            copyMainhook(mountPoint)
            createWinPE(mountPoint, f"{self.fullImgPath}.winpe", self.pathWinPEOverlay, self.partitionTable, self.elements.items())
            runWinPE(self.spicePort, self.fullImgPath, f"{self.fullImgPath}.winpe", self.winPeQemuCmdline)
            runWin(self.uuid, self.spicePort, self.fullImgPath, self.buildTimeout)            
            imgShrink(self.partitionTableTarget, self.fullImgPath, mountPoint)
            runWinPE(self.spicePort, self.fullImgPath, f"{self.fullImgPath}.winpe", self.winPeQemuCmdline)
        #Working with exceptions. There is a lot of work to do: We need to handle any critical exception.
        except (Exception,KeyboardInterrupt) as e:
            e_type, e_object, e_traceback = sys.exc_info()
            if (e_type==KeyboardInterrupt):
                finaliseBuild(mountPoint,self.fullImgPath, self.partitionTable)
                sendStatus(f"""❌*Build interupted*❌  
{self.uuid} was interrupted by keyboard!""")
                logger.error("KeyboardInterrupt Detected! Stopping.")
            else:
                logger.error(e)
                finaliseBuild(mountPoint,self.fullImgPath, self.partitionTable)
                sendStatus(f"""❌*Build failed!*❌  
Uploading log  {self.uuid} error: {e}""")
                sendFile(self.logPath)
            runCmd(f"virsh undefine --nvram {self.uuid}")
            runCmd(f"virsh destroy {self.uuid}")
            exit(1)
            
        finaliseBuild(mountPoint,self.fullImgPath, self.partitionTable)
        runCmd(f"virsh undefine --nvram {self.uuid}")
        runCmd(f"virsh destroy {self.uuid}")
        finalMessage=f"""✅*Image sucessfully builded*✅
ID: {self.uuid}
Versions:
```"""
        for element, version in self.elements.items():
            finalMessage+=f"""{element} {version}
"""
        finalMessage+="```"
        sendStatus(finalMessage)
        
    def test(self):
        logger.warning("Autotests: Work in progress")
