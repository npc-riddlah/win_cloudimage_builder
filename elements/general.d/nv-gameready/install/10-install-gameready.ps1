#Add-WindowsDriver -Path C:\ -Driver C:\drv\gameready\Display.Driver\nv_dispig.inf
${function:logInfo} = ${using:function:logInfo}
logInfo "Installing GameReady Driver"
pnputil.exe /add-driver C:\drv\gameready\Display.Driver\nv_dispi.inf /install
Remove-Item -Force -Path $PSCommandPath

exit
