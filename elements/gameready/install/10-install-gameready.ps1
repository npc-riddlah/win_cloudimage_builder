#Add-WindowsDriver -Path C:\ -Driver C:\drv\gameready\Display.Driver\nv_dispig.inf
pnputil.exe /add-driver C:\drv\gameready\Display.Driver\nv_dispig.inf
rm C:\drv\gameready -r -force

exit
