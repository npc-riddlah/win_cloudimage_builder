Import-Module PSWindowsUpdate

Test-PendingReboot -Detailed
if ( (Test-PendingReboot).IsRebootPending )
{
        Restart-Computer
        Stop-Process -Name "cmd" -Force
        Start-Sleep -Second 120.0
}
else
{
	Install-WindowsUpdate -AcceptAll -AutoReboot
	exit
}
