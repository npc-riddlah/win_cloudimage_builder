#$PSDefaultParameterValues['*:Encoding'] = 'utf8'
#Set-PSDebug -Trace 1
#Write-Output $OutputEncoding
#netsh advfirewall firewall set rule group="Дистанционное управление рабочим столом" new enable=yes
Set-NetFirewallRule -DisplayGroup "Remote Desktop" -Enabled True
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
exit
