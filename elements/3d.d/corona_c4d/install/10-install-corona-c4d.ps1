Start-Process -Wait -FilePath C:\tools\chaos-corona-12-update1-c4d-win.exe -ArgumentList "-gui=0 -auto"
Remove-Item -Force -Path $PSCommandPath
exit
