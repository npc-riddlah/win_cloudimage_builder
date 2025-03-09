${function:logInfo} = ${using:function:logInfo}

logInfo "Disabling update tray icon"
New-ItemProperty -Path HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings -Name TrayIconVisibility -Value 0
Remove-Item -Force -Path $PSCommandPath
