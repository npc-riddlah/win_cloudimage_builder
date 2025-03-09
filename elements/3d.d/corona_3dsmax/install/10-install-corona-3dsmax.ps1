Start-Process -Wait -FilePath C:\tools\chaos-corona-12-update-1-3dsmax.exe -ArgumentList "-gui=0 -auto"
Remove-Item -Force -Path $PSCommandPath

exit
