powershell "& ""Install-WindowsFeature -Name Wireless-Networking -Restart"""

sc config wlansvc start= auto
sc config audiosrv start= auto

exit
