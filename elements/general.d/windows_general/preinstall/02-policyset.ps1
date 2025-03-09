${function:logInfo} = ${using:function:logInfo}

logInfo "Enabling RDP Hardware Acceleration"
reg add 'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' /v bEnumerateHWBeforeSW /t REG_DWORD /d 1 /f
Remove-Item C:\hooks\preinstall\02-policyset.ps1 -Force
exit
