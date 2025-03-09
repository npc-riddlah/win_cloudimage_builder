#Add-WindowsDriver -Path C: -Driver C:\drv\grid\Display.Driver\nvgridsw.inf
pnputil.exe /add-driver C:\drv\grid\Display.Driver\nvgridsw.inf
Remove-Item -Force -Path $PSCommandPath

reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\GridLicensing" /v ServerAddress /t REG_SZ /d licenses.immers.cloud /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\GridLicensing" /v ServerPort /t REG_SZ /d 7070 /f
reg add "HKLM\SOFTWARE\NVIDIA Corporation\Global\GridLicensing" /v FeatureType /t REG_DWORD /d 2 /f

exit

Компьютер\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\nvlddmkm\Global\GridLicensing
