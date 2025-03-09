${function:logInfo} = ${using:function:logInfo}

logInfo "Disabling activation notification"
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\Activation -Name NotificationDisabled -Value 1
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\Activation -Name Manual -Value 1
Remove-Item -Force -Path $PSCommandPath
