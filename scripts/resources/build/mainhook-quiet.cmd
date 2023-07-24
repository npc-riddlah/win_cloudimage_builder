chcp 65001
cd "C:\hooks\preinstall\"
for /r %%v in (*.cmd) do start /wait /b %%v
for /r %%v in (*.ps1) do powershell "& ""%%v"""
cd "C:\hooks\install\"
for /r %%v in (*.cmd) do start /wait /b %%v
for /r %%v in (*.ps1) do powershell "& ""%%v"""
cd "C:\hooks\configure\"
for /r %%v in (*.cmd) do start /wait /b %%v
for /r %%v in (*.ps1) do powershell "& ""%%v"""
cd "C:\hooks\clean\"
for /r %%v in (*.cmd) do start /wait /b %%v
for /r %%v in (*.ps1) do powershell "& ""%%v"""

reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v ForceAutoLogon /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultDomainName /f
reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "mainhook" /f

del "C:\hooks\*" /f /q /s
shutdown /s /t 10
rmdir "C:\hooks\" /s /q 
del "C:\mainhook.cmd" /f /q /s
exit
