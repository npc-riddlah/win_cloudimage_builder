reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" /v bEnumerateHWBeforeSW /t REG_DWORD /d 1 /f
del C:\hooks\preinstall\preinstall\02-policyset.cmd /f /q & exit
exit
