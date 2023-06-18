cmd.exe /c "netsh advfirewall firewall set rule group='Дистанционное управление рабочим столом' new enable=yes"
cmd.exe /c "reg add 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server' /v fDenyTSConnections /t REG_DWORD /d 0 /f"
exit
