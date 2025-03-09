#Add-WindowsDriver -Path C: -Driver C:\drv\grid\Display.Driver\nvgridsw.inf
pnputil.exe /add-driver C:\drv\datacenter\Display.Driver\nv_dispswi.inf
Remove-Item -Force -Path $PSCommandPath
exit
