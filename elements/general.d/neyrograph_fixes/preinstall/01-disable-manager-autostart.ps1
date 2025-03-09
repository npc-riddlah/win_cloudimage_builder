Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask
Remove-Item -Force -Path $PSCommandPath
