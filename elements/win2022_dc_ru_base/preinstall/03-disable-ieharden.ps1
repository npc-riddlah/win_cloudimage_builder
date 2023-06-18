cmd.exe /c "reg add 'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings' /v ZoneMap /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add 'HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings' /v ZoneMap /t REG_DWORD /d 0 /f"
cmd.exe /c "reg add 'HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings' /v ZoneMap /t REG_DWORD /d 0 /f"
Remove-Item C:\hooks\preinstall\03-disable-ieharden.ps1 -Force
exit
