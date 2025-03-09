Start-Process -Wait -FilePath C:\tools\deadline-client.exe -ArgumentList "--mode unattended"
Remove-Item -Force -Path $PSCommandPath
exit
