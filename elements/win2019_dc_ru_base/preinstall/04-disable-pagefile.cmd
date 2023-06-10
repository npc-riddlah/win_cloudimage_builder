wmic computersystem set AutomaticManagedPagefile=False
wmic pagefileset delete
del /f /q /a C:\hooks\preinstall\04-disable-pagefile.cmd & exit
