Copy-Item ([Environment]::GetFolderPath("Desktop"))\* C:\users\public\desktop
cmd.exe /c reg delete "HKLM\SOFTWARE\Cloudbase Solutions" /f

Remove-Item -Force -Path $PSCommandPath
exit
