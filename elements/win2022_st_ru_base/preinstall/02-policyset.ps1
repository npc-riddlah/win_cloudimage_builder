cmd.exe /c "reg add 'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' /v bEnumerateHWBeforeSW /t REG_DWORD /d 1 /f"
Remove-Item C:\hooks\preinstall\preinstall\02-policyset.ps1 -Force
exit