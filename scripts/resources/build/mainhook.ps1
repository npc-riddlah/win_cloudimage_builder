chcp 65001

reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /t REG_DWORD /v "IRPStackSize" /d 32 /f

Get-ChildItem 'C:\hooks\preinstall' | ForEach-Object {
  & $_.FullName
}

Get-ChildItem 'C:\hooks\install' | ForEach-Object {
  & $_.FullName
}

Get-ChildItem 'C:\hooks\configure' | ForEach-Object {
  & $_.FullName
}

Get-ChildItem 'C:\hooks\clean' | ForEach-Object {
  & $_.FullName
}

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
