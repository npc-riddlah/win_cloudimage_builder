#!/usr/bin/python3
import os, sys, queue, configparser, importlib

pathDefaultConfig = "./conf/winbuilder.conf"

buildQueue=queue.Queue()
imageConfigFile = configparser.ConfigParser(allow_no_value=True)
imageConfigFile.optionxform = str

#Loading configs from commandline arguments
for imageconfig in sys.argv[1:]:
    if (os.path.isfile(imageconfig)):
        imageConfigFile.read(imageconfig)
        if 'builder' in imageConfigFile['SETTINGS']:
            builderName = f"builders.{imageConfigFile['SETTINGS']['builder']}"
        else:
            #Reading default config if imageconfig does not specify builder.
            #Todo: Exception while it is not specified in default config.
            #Maybe do check is default config has all the parameters defined?
            imageConfigFile.read(pathDefaultConfig)
            builderName = f"builders.{imageConfigFile['DEFAULTS']['builder']}"
        builder = importlib.import_module(builderName) #Importing builder module
        buildQueue.put(builder.imageRunner(imageconfig))
        print(f"Config import success: {imageconfig}")
    else:
        print(f"IGNORING! imageConfigFile not found: {imageconfig}")
        
#Running configs. Todo: Parallel runs.
for i in range(buildQueue.qsize()):
    imgInstance = buildQueue.get()
    uploader = importlib.import_module(f"uploaders.{imgInstance.uploader}")
    imgInstance.build()
    imgInstance.test()
    uploader.start(imgInstance)
