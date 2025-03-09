$SystemLocale = Get-WinSystemLocale

if ($SystemLocale.Name -like "*en*"){
	Copy-Item -Path "C:\conf-en\*" -Destination "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\" -Force
} else {
	Copy-Item -Path "C:\conf\*" -Destination "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\" -Force
}
exit
