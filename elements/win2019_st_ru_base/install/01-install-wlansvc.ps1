echo "Installing wlansvc..."

Install-WindowsFeature -Name Wireless-Networking -IncludeAllSubFeature -Restart

cmd.exe /c "sc config wlansvc start=auto"
cmd.exe /c "sc config audiosrv start=auto"
cmd.exe /c "del /f /q /a C:\hooks\install\01-install-wlansvc.ps1"

exit
