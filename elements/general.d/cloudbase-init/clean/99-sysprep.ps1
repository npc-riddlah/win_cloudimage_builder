${function:logInfo} = ${using:function:logInfo}
$SystemLocale = Get-WinSystemLocale
logInfo "Cleaning and sysprepping with cloudbase-init"
Start-Sleep -Seconds 60.0

if ($SystemLocale.Name -like "*en*") {
	logInfo "Detected EN Locale. Disabling Administrator"
	try {
		Disable-LocalUser Administrator
	} catch {
		logError "Something wrong! Administrator disabling failed"
	}
} else {
	try {
		Disable-LocalUser Administrator
	} catch {
		logError "Something wrong! Administrator disabling failed"
	}
}
cmd.exe /c c:\windows\system32\sysprep\sysprep.exe /oobe /generalize /quit /unattend:c:\progra~1\cloudb~1\cloudb~1\conf\Unattend.xml
Start-Sleep -Seconds 60.0
exit
