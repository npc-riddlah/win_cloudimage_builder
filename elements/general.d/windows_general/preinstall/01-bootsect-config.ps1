${function:logInfo} = ${using:function:logInfo}

logInfo "Disabling bootsect timeout"
cmd.exe /c "bcdedit /timeout 1"
Remove-Item C:\hooks\preinstall\01-bootsect-config.ps1 -Force
exit
