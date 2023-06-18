wmic computersystem set AutomaticManagedPagefile=False
wmic pagefileset delete
Remove-Item C:\hooks\preinstall\04-disable-pagefile.ps1 -Force
exit
