logInfo "Installing Auto1111"
loginfo "Init..."
New-Item -Path "C:\Software" -ItemType Directory
cd C:\Software

#Prebuild installation way
Invoke-WebRequest -Uri "https://github.com/AUTOMATIC1111/stable-diffusion-webui/releases/download/v1.0.0-pre/sd.webui.zip" -OutFile ".\sd.webui.zip"
Expand-Archive .\sd.webui.zip -DestinationPath .\stable-diffusion-webui
cd stable-diffusion-webui
.\update.bat


#Alternative installation way
#git clone -b dev https://github.com/AUTOMATIC1111/stable-diffusion-webui.git --single-branch
#cd stable-diffusion-webui
#.\webui-user.bat
#deactivate

loginfo "Done!"
