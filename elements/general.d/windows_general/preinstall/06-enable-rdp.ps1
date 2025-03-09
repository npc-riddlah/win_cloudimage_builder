${function:logInfo} = ${using:function:logInfo}
$SystemLocale = Get-WinSystemLocale

if ($SystemLocale.Name -like "*en*"){
	logInfo "Detected EN Locale. Enabling Latin-symbol RDP rule"
	Set-NetFirewallRule -DisplayGroup "Remote Desktop" -Enabled True
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
}
else {
	logInfo "Detected Non-EN Locale. Enabling Cyrilling-symbol RDP rule"
	Set-NetFirewallRule -DisplayGroup "Дистанционное управление рабочим столом" -Enabled True
	reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
}
exit
