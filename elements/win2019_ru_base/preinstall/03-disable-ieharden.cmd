reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ZoneMap /t REG_DWORD /d 0 /f
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\Internet Settings" /v ZoneMap /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings" /v ZoneMap /t REG_DWORD /d 0 /f
exit
