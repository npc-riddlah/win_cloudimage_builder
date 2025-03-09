Start-Sleep -Seconds 120
msiexec.exe /i C:\tools\GoogleChromeStandaloneEnterprise64.msi /qb 
Remove-Item -Force -Path $PSCommandPath
exit
