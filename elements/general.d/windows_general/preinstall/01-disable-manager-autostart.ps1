${function:logInfo} = ${using:function:logInfo}

logInfo "Disable ServerManager Autostart"
Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask
Remove-Item -Force -Path $PSCommandPath
