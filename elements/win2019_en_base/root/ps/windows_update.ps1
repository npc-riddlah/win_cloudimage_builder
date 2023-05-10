Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -force
Install-Module -Name PSWindowsUpdate -force

Import-Module PSWindowsUpdate

Install-WindowsUpdate -AcceptAll -AutoReboot

exit
