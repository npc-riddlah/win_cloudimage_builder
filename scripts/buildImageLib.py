#!/usr/bin/python3
import os, sys, subprocess, configparser, certifi, requests, logging, io, shutil, uuid, json, parted, importlib
from distutils.dir_util import copy_tree
from keystoneauth1 import loading
from keystoneauth1 import identity
from keystoneauth1 import session
from contextlib import redirect_stdout
from copy import deepcopy
from datetime import datetime

#Params
pathDefaultConfig = "./conf/winbuilder.conf"

#Settting up logs
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.DEBUG)
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)

#Integrations init
if (os.path.isfile(pathDefaultConfig)):
    print("General config detected")

    intModules=[]
    integrations=[]
    configFile = configparser.ConfigParser(allow_no_value=True)
    configFile.optionxform = str
    configFile.read(pathDefaultConfig)
    i=0
    for intModule in configFile['INTEGRATIONS']:
        intModuleName = f"integrations.{intModule}"
        intModules.append(importlib.import_module(intModuleName))
        integrations.append(intModules[i].integrator())
        i+=1
    #Setting up Telegram API

def sendStatus(message):
    try:
        integrations
    except:
        pass
    else:
        for integration in integrations:
            integration.sendMsg(message)
def sendFile(filePath):
    try:
        integrations
    except:
        pass
    else:
        for intModule in integrations:
            intModule.sendMsg(message)

def throwError(errorMsg):
    logger.error(errorMsg)
    raise Exception(errorMsg)

def runCmd(command):
    logger.debug(f"Running command: {command}")
    subprocess.run(command, shell=True)

def runCmdStdOut(command, timeout=20000):
    if type(timeout) is str:
        timeout = float(timeout)

    def log_subproccess(pipe):
        for line in iter(pipe.readline, b''):
            logger.info(f"Stdout: {line}")

    try:
        proccess = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        output = proccess.stdout.read()
        with proccess.stdout:
            log_subproccess(proccess.stdout)
        proccess.wait(timeout)
    except (Exception, KeyboardInterrupt) as error:
        throwError(f"Something went wrong! Error: {error}")
    return output

def getSystemPartNumber(table):
    for partition in table:
        if 'system' in table[partition]:
            if (table[partition]['system'] == "true"):
                logger.debug(f"Detected system partition. Name: {partition} Number: {list(table.keys()).index(partition)+1}")
                return list(table.keys()).index(partition)+1
                break

def getLoPath(imgPath):
    command = ["losetup", "-n", "-l", "-O", "NAME", "-j", imgPath]
    logger.debug(f"Loop search command: {command}")
    proc = subprocess.Popen(command, stdout=subprocess.PIPE)
    loopPath = proc.stdout.read().decode('utf-8').rstrip().splitlines(True)
    logger.debug(f"LoSetup paths acquired: {loopPath}")
    return loopPath

def createLoPath(imgPath):
    command = ["losetup", "--partscan", "--show", "--find", imgPath]
    logger.debug(f"Creating new loop path: {command}")
    proc = subprocess.Popen(command, stdout=subprocess.PIPE)
    loopPath = proc.stdout.read().decode('utf-8').rstrip()
    logger.debug(f"Created loop path: {loopPath} : {imgPath}")
    return loopPath

def removeLoPath(loopPath, table):

    for line in loopPath:
        logger.debug(f"Deleting loop device: {line}")
        sysPartNum = getSystemPartNumber(table)
        runCmd(f"umount {loopPath}p{sysPartNum}") #Todo: umount defined in partition settings system partition, not p2
        runCmd(f"losetup -d {line}")

#Mounting and umounting ISO file.
def isoMount(mountPoint, isoPath):
    logger.info(f"Mounting ISO: {isoPath} to {mountPoint}/iso")
    if not (os.path.isdir(f"{mountPoint}/iso")):
        os.makedirs(f"{mountPoint}/iso", exist_ok=True)
    #Todo: Exception on exitcode
    runCmd(f"mount -o loop {isoPath} {mountPoint}/iso")

def isoUmount(mountPoint):
    #Todo: While target is busy?
    logger.info(f"Unmounting: {mountPoint}/iso")
    runCmd(f"umount {mountPoint}/iso")

#Mounting and umounting RAW image file
def rawAttach(rawPath):
    logger.debug("Attaching RAW image as loop device")
    return createLoPath(rawPath)

def rawDetach(rawPath,table):
    logger.debug("Detaching RAW image as loop device")
    loopPath=getLoPath(rawPath)
#    runCmd(f"ntfsfix -b -d {loopPath}p2")
    removeLoPath(loopPath, table)

def rawMount(mountPoint, rawPath, table):
    logger.info(f"Mounting RAW: {rawPath} to {mountPoint}/raw")
    if not (os.path.isdir(f"{mountPoint}/raw")):
        os.makedirs(f"{mountPoint}/raw", exist_ok=True)
    #Todo: Exception on exitcode
    sysPartNum = getSystemPartNumber(table)
    pathLoop = getLoPath(rawPath)
    runCmd(f"mount -t ntfs-3g {pathLoop[0]}p{sysPartNum} {mountPoint}/raw") #Todo: mount defined in partition settings system partition, not p2
    runCmd(f"ls {mountPoint}/raw")

def rawUmount(mountPoint):
    logger.info(f"Unmounting: {mountPoint}/raw")
    runCmd(f"umount {mountPoint}/raw")

#Getting disk size from table
def diskSizeFromTable(table):
    diskSizeBytes=0
    for partition in table:
        logger.debug(f"Detected size of {partition} is {table[partition]['size']}")
        size = table[partition]["size"]
        match table[partition]["size"][-1]:
            case 'K':
                size=int(size.removesuffix('K'))
                table[partition]["sizeBytes"]=str(size*1024)
            case 'M':
                size=int(size.removesuffix('M'))
                table[partition]["sizeBytes"]=str(size*1024*1024)
            case 'G':
                size=int(size.removesuffix('G'))
                table[partition]["sizeBytes"]=str(size*1024*1024*1024)
            case 'T':
                size=int(size.removesuffix('T'))
                table[partition]["sizeBytes"]=str(size*1024*1024*1024*1024)
            case _:
                log.error(f"Define the measure for size of {partition}: [K, M, G, T]. At example: 25G")
                pass
        diskSizeBytes+=int(table[partition]["sizeBytes"])
    return diskSizeBytes
#Getting partition size from table
def partSizeFromTable(table, partNum):
    partition = list(table)[partNum-1]
    logger.debug(f"Detected size of {partition} is {table[partition]['size']}")
    size = table[partition]["size"]
    match size[-1]:
        case 'K':
            size=int(size.removesuffix('K'))
            table[partition]["sizeBytes"]=str(size*1024)
        case 'M':
            size=int(size.removesuffix('M'))
            table[partition]["sizeBytes"]=str(size*1024*1024)
        case 'G':
            size=int(size.removesuffix('G'))
            table[partition]["sizeBytes"]=str(size*1024*1024*1024)
        case 'T':
            size=int(size.removesuffix('T'))
            table[partition]["sizeBytes"]=str(size*1024*1024*1024*1024)
        case _:
            log.error(f"Define the measure for size of {partition}: [K, M, G, T]. At example: 25G")
            pass
    return table[partition]["sizeBytes"]
#Creating disk image file
def imgGptCreate(table, rawPath, targetSize="0"):
    #TODO: ADDITIONAL CHECKS!!!!: Dir Path existance, rawPath not empty
    logger.info(f"Creating RAW Image file: {rawPath}")
    logger.debug(f"Partition table:")
    for partition in table:
        logger.debug(f"Name: {partition}")
        for key, value in table[partition].items():
            logger.debug(f"    {key} = {value}")
    latestPartIndex=list(table)[-1]
    logger.debug("Calculating partition sizes...")
    if (targetSize!="0"):  #TODO!!!: Not last partition, just system. Recalculate partitions sizes after system one
        logger.debug(f"Changing final partition size to {targetSize}")
        logger.debug(f"Latest part index: {latestPartIndex}")
        table[latestPartIndex]["size"]=targetSize 
    diskSizeBytes = diskSizeFromTable(table)
    logger.debug(f"Detected disk size: {diskSizeBytes} bytes. Creating file.")
    runCmd(f"qemu-img create -f raw -o size={diskSizeBytes} {rawPath}")
    image = parted.getDevice(rawPath)
    disk = parted.freshDisk(image,"gpt")
    logger.debug("Partitioning image file...")
    #Using that variable to drive through whole disk size mapping partitionss. Starting from 2048 as GPT wants
    prevPartSize=2048
    for partition in table:
        partSize=(int(table[partition]["sizeBytes"])//512)
        logger.debug(f"{partition} size: {partSize} bytes")
        partGeo = parted.Geometry(device=image, start=prevPartSize, length=prevPartSize+partSize)
        partFS = parted.FileSystem(type=table[partition]["filesystem"], geometry=partGeo)
        part = parted.Partition(disk=disk, type=parted.PARTITION_NORMAL, fs=partFS, geometry=partGeo)
        if "flags" in table[partition]:
            logger.debug(f"Detected partition flags: {table[partition]['flags']}")
            flags = table[partition]['flags'].split(';')
            for flag in flags:
                part.setFlag(getattr(parted, flag))
        part.name=partition
        disk.addPartition(partition=part, constraint=image.optimalAlignedConstraint)
        disk.commit()
        table[partition]["beginOffsetSector"]=str(prevPartSize)
        table[partition]["endOffsetBytes"]=str(prevPartSize+partSize)
        table[partition]["beginOffsetBytes"]=str(prevPartSize*512)
        table[partition]["endOffsetBytes"]=str((prevPartSize+partSize)*512)
        prevPartSize+=partSize

    #Todo: Handling formatting. I think we will rewrite it again later... maybe... It is bottleneck in our possibility to dynamically use filesystems names
    logger.info("Formatting...")
    loopPath = rawAttach(rawPath)
    for partition in table:
        partIndex = list(table.keys()).index(partition) + 1
        match table[partition]["filesystem"]:
            case "fat32":
                runCmd(f"mkfs.vfat {loopPath}p{partIndex} -F32")
            case "ntfs":
                runCmd(f"mkfs.ntfs {loopPath}p{partIndex} -Q -v -F -p {int(table[partition]['beginOffsetSector'])} -s 512 -S 32 -H 1")
    logger.info("Image created!")
    return loopPath

#Extracting Windows WIM archive
def extractWIM(mountPoint, rawFile, editionName, table):
    logger.info(f"Extracting WIM: {mountPoint}/iso/sources/install.wim - {editionName}")
    pathLoop = getLoPath(rawFile)
    if not pathLoop:
        throwError("There is no loop device where we must extract WIM")
    if len(pathLoop) > 1:
        throwError("More than one loop device per RAW image. Clean it and run again")
    sysPartNum = getSystemPartNumber(table)
    runCmd(f"wimapply {mountPoint}/iso/sources/install.wim '{editionName}' {pathLoop[0]}p{sysPartNum}") #Extract to defined in partition settings system partition, not p2

#Copying Unattend.XML to Windows Installation
def copyUnattend(fromPath, mountPoint):
    logger.info(f"Copying Unattend.xml from {fromPath} to {mountPoint}/raw/Windows/Panther/Unattend.xml")
    os.makedirs(f"{mountPoint}/raw/Windows/Panther")
    shutil.copy(fromPath, f"{mountPoint}/raw/Windows/Panther/Unattend.xml")
    
#Copying mainhook.ps1 to Windows Installation
def copyMainhook(mountPoint):
    logger.info(f"Copying Mainhook from {os.getcwd()}/resources/build/mainhook.ps1 to {mountPoint}/raw/mainhook.ps1")
    shutil.copy(f"{os.getcwd()}/resources/build/mainhook.ps1", f"{mountPoint}/raw/mainhook.ps1") #Maybe change original mainhook path to sys neutral?    

#Preparing element
def prepareElement(elementPath, mountPoint):
  logger.info(f"Preparing element: {elementPath}")
  if (os.path.isdir(f"{elementPath}/prerun")):
    envVars = os.environ.copy()
    envVars["WCB_PATH_SYSPART"] = f"{mountPoint}/raw"
    envVars["WCB_PATH_ISO"] = "f{mountPoint}/iso"
    envVars["WCP_PATH_ELEMENT"] = elementPath
    for file in os.listdir(f"{elementPath}/prerun"):
      if (os.path.isfile(f"{elementPath}/prerun/{file}")):
        logger.debug(f"Running script {file}...")
        print(subprocess.run(f"{elementPath}/prerun/{file}", shell=True, env=envVars))

#Copying element to Windows Installation:
def copyElement(elementPath, mountPoint):
    logger.info(f"Copying element: {elementPath}")
    if (os.path.isdir(f"{elementPath}/root")):
        logger.debug("Copying root overlay...")
        copy_tree(f"{elementPath}/root",f"{mountPoint}/raw")

    subdirs=["preinstall", "install", "configure", "clean"]
    for dir in subdirs:
        logger.debug(f"Copying subdir: {dir}")
        if not (os.path.isdir(f"{mountPoint}/raw/hooks/{dir}")):
            logger.debug(f"Subdir not found. Creating {mountPoint}/raw/hooks/{dir}")
            os.makedirs(f"{mountPoint}/raw/hooks/{dir}", exist_ok=True)
        if (os.path.isdir(f"{elementPath}/{dir}")):
            copy_tree(f"{elementPath}/{dir}",f"{mountPoint}/raw/hooks/{dir}")

#Creating WinPE Image to boot and install bootloader in official way
def createWinPE(mountPoint, savePath, pathWinPEOverlay, table, elements):
    logger.info(f"Creating WinPE image with overlay {os.getcwd()}/resources/winpe. Saving to {savePath}")
    sysPartNum = getSystemPartNumber(table)
    if not (os.path.isdir(f"{savePath}.d")):
        os.makedirs(f"{savePath}.d", exist_ok=True)
    else:
        logger.debug("Detected old cache. Removing")
        shutil.rmtree(f"{savePath}.d")
        os.makedirs(f"{savePath}.d", exist_ok=True)
    copy_tree(pathWinPEOverlay,f"{savePath}.d")
    with open(f"{savePath}.d/diskpart_assign.txt", "w") as diskPartCfg: #Todo: Proccess BOOT volume too later. At this time boot is first in all of cases.
        diskPartCfgText=f"""sel disk 0
sel volume 1
assign letter c
sel volume {sysPartNum}
assign letter e
exit"""
        diskPartCfg.write(diskPartCfgText)
    
    #Copying winpe stage of elements
    if not (os.path.isdir(f"{savePath}.d")):
        os.makedirs(f"{savePath}.d/hooks", exist_ok=True)
    for element, version in elements:           #Todo: Maybe split to hooks and data? Or custom subdir in winpe root? We need to think more.
        if os.path.isdir(f"{element}/wperoot"):
            logger.debug(f"Copying WinPE Element Stage of {element}")
            copy_tree(f"{element}/wperoot", f"{savePath}.d")
    runCmd(f"mkwinpeimg -i -O '{savePath}.d' -a amd64 -W {mountPoint}/iso {savePath}")
    pass

#Running WinPE image. Installing bootloader and something else what you put in overlay
def runWinPE(spicePort, rawPath, winPePath, cmdLine=""):
    logger.info("Running QEMU with WinPE. Installing bootloader.")
    if (spicePort == "0"):
        command = f"qemu-system-x86_64 -machine q35 -accel kvm -m 4096 -hda {rawPath} -boot d -cdrom {winPePath} {cmdLine} -vga cirrus -display none"
    else:
        logger.info(f"Spice port is {spicePort}")
        command = f"qemu-system-x86_64 -machine q35 -accel kvm -m 4096 -hda {rawPath} -boot d -cdrom {winPePath} {cmdLine} -vga cirrus -spice port={spicePort},addr=0.0.0.0,disable-ticketing=on"
    try:
        runCmd(command)
    except (Exception, KeyboardInterrupt) as error:
        throwError(error)
        
#Running main windows machine to install OS and elements
def runWin(buildId, spicePort, rawPath, timeout=20000):
    if type(timeout) is str:
        timeout = float(timeout)

    def log_subproccess(pipe):
        for line in iter(pipe.readline, b''):
            logger.info(f"Windows: {line}")
        
    logger.info("Running Libvirt with RAW Image. Installing elements and preparing system.")
    command = ["virt-install", "--name", f"{buildId}", "--memory", "8192", "--vcpus", "8", "--cpu", "host-model-only", "--boot", "uefi,loader.secure='no'", "--disk", f"{rawPath},target.bus=virtio", "--graphics", "none", "--osinfo", "win2k22", "--console", "pty,target_type=serial", "--install", "no_install=yes"]
    if not (spicePort == "0"):
        logger.info(f"Spice port is {spicePort}")
        command +=["--xml", "xpath.delete=./devices/graphics", "--xml", "./devices/graphics/@type=spice", "--xml", f"./devices/graphics/@port={spicePort}", "--xml", "./devices/graphics/@autoport=no", "--xml", "./devices/graphics/@defaultMode=insecure", "--xml", "./devices/graphics/@listen=0.0.0.0"]
    try:
        logger.debug(f"Running command: {command}")
        proccess = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
        with proccess.stdout:
            log_subproccess(proccess.stdout)
        proccess.wait(timeout)
    except (Exception, KeyboardInterrupt) as error:
        throwError(f"Something went wrong! Error: {error}")

def finaliseBuild(mountPoint, rawPath, table):
    #Todo: checks of paths existance
    isoUmount(mountPoint)
    rawUmount(mountPoint)
    rawDetach(rawPath, table)
    rawDetach(f"{rawPath}.target", table)
    if os.path.isdir(mountPoint):
        logger.info(f"Removing mountpoint: {mountPoint}")
        shutil.rmtree(mountPoint)

#Shrinking image
def imgShrink(table, rawPath, mountPoint):
    #Todo: auto size allocations defined on parent image FS usage
    rawUmount(mountPoint)
    targetLoopPath = imgGptCreate(table, f"{rawPath}.target")
    parentLoopPath = getLoPath(rawPath)
    logger.info("Shrinking NTFS on parent image")
    sysPartNum = getSystemPartNumber(table)
    sysPartName = list(table)[sysPartNum-1]
    runCmd(f"ntfsresize -f -s {table[sysPartName]['size']} {parentLoopPath[0]}p{sysPartNum}") #Change partition to partition which set in partition config! Also we need to get name of selected partition
    logger.info("Moving data to the new image")
    sysPartNum = getSystemPartNumber(table)
    runCmd(f"dd if={parentLoopPath[0]}p{sysPartNum} of={targetLoopPath}p{sysPartNum} bs=1M status=progress")  #DD from and to defined in partition settings system partition, not p2
    finaliseBuild(mountPoint, rawPath, table)
    logger.debug("Removing parent image and renaming target image")
    os.remove(rawPath)
    os.rename(f"{rawPath}.target", rawPath)
    logger.info("Build done!")

#Parsing partition settings from config
def loadPartitions(configFile):
    partTable={}
    partFoundFlag=False
    for partition in configFile:
        if "PARTITION." in partition:
            partitionName = partition.split('.')[-1]
            partTable[partitionName] = configFile[partition]
            logger.debug(f"Partition detected: {partitionName} {partTable[partitionName]['size']} {partTable[partitionName]['filesystem']}")
            partFoundFlag=True
    if not partFoundFlag:
        return False
    else:
        return partTable

def checkPartTableConsistency(table):
    logger.debug("Checking partition table from config...")
    hasSystemPart=False
    for partition in table:
        if 'system' in table[partition]:
            if (table[partition]['system'] == "true"):
                logger.debug(f"Detected system partition. Name: {partition} Number: {list(table.keys()).index(partition)+1}")
                hasSystemPart=True
    
    if not(hasSystemPart):
        throwError("System partition is not defined in config. Please, add 'system=true' to one of partition sections which one you want to install windows.")

def formatString(text):
    time = datetime.now()
    text=text.replace("$date", f"{time.strftime('%b %Y')}")
    return text
    
#Basic image looks like this
class Image:
    def __init__(self, imageconfig):
        logger = logging.getLogger(__name__)
    ##############################
    ####Loading default config####
    ##############################
        logger.info("\n\n============\nLoading default config...\n============\n")
        #Unconditional defaults
        self.spicePort="0"
        self.winPeQemuCmdline=''
        self.elements={}
        self.elementsVer={}
        self.envvars={}
        self.osImgID=''
        self.builder=''
        self.uploader=''
        self.builder=''
        self.uploader=''
        self.osSrvID=''
        self.buildTimeout="30000"
        self.pathWinPEOverlay="./resources/winpe"
        self.pathUnattend="./resources/build/unattend.xml_default"
        self.partitionTable={}
        #Getting all of parameters from default config file and defining it as class variables
        if (os.path.isfile(pathDefaultConfig)):
            defaultConfigFile = configparser.ConfigParser(allow_no_value=True)
            defaultConfigFile.optionxform = str
            defaultConfigFile.read(pathDefaultConfig)
            if defaultConfigFile.has_section("DEFAULTS"):
                for setting in defaultConfigFile['DEFAULTS']:
                    setattr(self, setting, formatString(defaultConfigFile['DEFAULTS'][setting]))
                    logger.debug(f"Default parameter defined: {setting} = {formatString(defaultConfigFile['DEFAULTS'][setting])}")
            else:
                logger.warning("Default config defined but DEFAULTS section not found")
                
            
            #Default Partition table loading
            self.partitionTable = loadPartitions(defaultConfigFile)
            if not self.partitionTable:
                logger.warning("Partitions setup not found in default config!")
                    
    #################################                 
    ####Loading image config file####
    #################################
        logger.info("\n\n============\nLoading image config...\n============\n")
        if (os.path.isfile(imageconfig)):
            configFile = configparser.ConfigParser(allow_no_value=True)
            configFile.optionxform = str
            configFile.read(imageconfig)
        else:
            throwError(f"Image config not found: {imageconfig}")

        #Configuring Logging. One per image instance
        logPath=f"{configFile['SETTINGS']['pathSave']}/{configFile['SETTINGS']['name']}.log"
        if (os.path.isfile(logPath)):
            os.remove(logPath)
        logging.basicConfig(filename=logPath, level=logging.DEBUG)
        logger = logging.getLogger(__name__)
        logger.info(f"Importing image config: {imageconfig}")

        #Plain imageconfig parameters
        #Getting all of parameters from image config file and defining it as class variables
        if configFile.has_section("SETTINGS"):
            for setting in configFile['SETTINGS']:
                setattr(self, setting, formatString(configFile['SETTINGS'][setting]))
                logger.debug(f"Image parameter defined: {setting} = {formatString(configFile['SETTINGS'][setting])}")
        else:
            throwError(f"SETTINGS section not found in {imageconfig}")
        
        #Calculated imageconfig parameters
        self.logPath=logPath
        self.fullImgPath=self.pathSave+"/"+self.name+".raw"
        self.uuid = uuid.uuid4()
        
        #Parsing environment variables
        if configFile.has_section("EXPORTS"):
            logger.info("Custom environment variables:")
            for item in configFile['EXPORTS']:
                self.envvars[item]=configFile['EXPORTS'][item]
                logger.info(self.envvars)
        
        #Getting elements and versions
        for element in configFile['ELEMENTS']:
            if os.path.isdir(element):
                if os.path.isfile(f"{element}/version.txt"):
                    verFile = open(f"{element}/version.txt", 'r')
                    elementVersion = verFile.read(255)
                    self.elements[element] = f"{elementVersion}"
                    verFile.close()
                else:
                    self.elements[element]="none"
