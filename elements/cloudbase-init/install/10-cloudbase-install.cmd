echo "Pending reboot:"
Test-PendingReboot -Detailed
if ( (Test-PendingReboot).IsRebootPending )
{
        Restart-Computer
        Stop-Process -Name "cmd" -Force
        Start-Sleep -Second 120.0
}
else
{
	msiexec /i "C:\tools\CloudbaseInitSetup_1_1_4_x64.msi" /qb /l* "C:/log.txt"
	exit
}
