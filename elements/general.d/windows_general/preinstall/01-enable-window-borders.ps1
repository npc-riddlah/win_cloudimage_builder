${function:logInfo} = ${using:function:logInfo}

logInfo "Enabling visual settings"
Remove-Item -Path HKLM:\Software\Microsoft\Windows\DWM\EnableWindowColorization
Remove-Item -Path HKLM:\Software\Microsoft\Windows\DWM\ColorPrevalence
Remove-Item -Path HKCU:\Software\Microsoft\Windows\DWM\EnableWindowColorization
Remove-Item -Path HKCU:\Software\Microsoft\Windows\DWM\ColorPrevalence
Remove-Item -Path HKU:\Software\Microsoft\Windows\DWM\EnableWindowColorization
Remove-Item -Path HKU:\Software\Microsoft\Windows\DWM\ColorPrevalence
Remove-Item -Path HKU:\.Default\Software\Microsoft\Windows\DWM\EnableWindowColorization
Remove-Item -Path HKU:\.Default\Software\Microsoft\Windows\DWM\ColorPrevalence
Remove-Item -Path HKU:\Default\Software\Microsoft\Windows\DWM\EnableWindowColorization
Remove-Item -Path HKU:\Default\Software\Microsoft\Windows\DWM\ColorPrevalence

Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\DWM -Name EnableWindowColorization -Value 1
Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\DWM -Name ColorPrevalence -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\DWM -Name EnableWindowColorization -Value 1
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\DWM -Name ColorPrevalence -Value 1
Set-ItemProperty -Path HKU:\Software\Microsoft\Windows\DWM -Name EnableWindowColorization -Value 1
Set-ItemProperty -Path HKU:\Software\Microsoft\Windows\DWM -Name ColorPrevalence -Value 1
Set-ItemProperty -Path HKU:\.Default\Software\Microsoft\Windows\DWM -Name EnableWindowColorization -Value 1
Set-ItemProperty -Path HKU:\.Default\Software\Microsoft\Windows\DWM -Name ColorPrevalence -Value 1
Set-ItemProperty -Path HKU:\Default\Software\Microsoft\Windows\DWM -Name EnableWindowColorization -Value 1
Set-ItemProperty -Path HKU:\Default\Software\Microsoft\Windows\DWM -Name ColorPrevalence -Value 1

$RegistryKey = "HKCU:Control Panel\Desktop"
$Name = "UserPreferencesMask"
$Value = ([byte[]](0x90,0x32,0x07,0x80,0x10,0x00,0x00,0x00))
$Type = "Binary"
New-ItemProperty -Path $RegistryKey -Name $Name -Value $Value -PropertyType $Type -Force

$RegistryKey = "HKU:Control Panel\Desktop"
$Name = "UserPreferencesMask"
$Value = ([byte[]](0x90,0x32,0x07,0x80,0x10,0x00,0x00,0x00))
$Type = "Binary"
New-ItemProperty -Path $RegistryKey -Name $Name -Value $Value -PropertyType $Type -Force

$RegistryKey = "HKLM:Control Panel\Desktop"
$Name = "UserPreferencesMask"
$Value = ([byte[]](0x90,0x32,0x07,0x80,0x10,0x00,0x00,0x00))
$Type = "Binary"
New-ItemProperty -Path $RegistryKey -Name $Name -Value $Value -PropertyType $Type -Force




# Load the offline registry hive from the OS volume
$HivePath = "C:\Users\Default\NTUSER.DAT"
New-PSDrive -PSProvider Registry -Root HKEY_USERS -Name HKU
reg load "HKU\Tmp" $HivePath 
Start-Sleep -Seconds 5

# Updating default registry hive to show Windows Borders
$RegistryKey = "HKU:Tmp\Control Panel\Desktop"
$Name = "UserPreferencesMask"
$Value = ([byte[]](0x90,0x32,0x07,0x80,0x10,0x00,0x00,0x00))
$Type = "Binary"
New-ItemProperty -Path $RegistryKey -Name $Name -Value $Value -PropertyType $Type -Force

New-ItemProperty -Path HKU:Tmp\Software\Microsoft\Windows\DWM -Name EnableWindowColorization -Value 1
New-ItemProperty -Path HKU:Tmp\Software\Microsoft\Windows\DWM -Name ColorPrevalence -Value 1

# Cleanup (to prevent access denied issue unloading the registry hive)
Get-Variable Registry* | Remove-Variable
[gc]::collect()
Start-Sleep -Seconds 5

Remove-Item -Force -Path $PSCommandPath
