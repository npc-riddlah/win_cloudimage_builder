#slmgr.vbs -ipk VDYBN-27WPP-V4HQT-9VMD4-VMK7H
#slmgr.vbs -skms kms.srv.crsoo.com
#slmgr.vbs -ato
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\Activation -Name NotificationDisabled -Value 1
Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform\Activation -Name Manual -Value 1
Remove-Item -Force -Path $PSCommandPath
