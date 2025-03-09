${function:logInfo} = ${using:function:logInfo}
${function:logError} = ${using:function:logError}

try{
	logInfo "Installing Davinci Resolve"
	Start-Process -Wait -FilePath "C:/tools/davinci/DaVinci_Resolve_19.1.1_Windows.exe" -ArgumentList "/i /q /noreboot"
	
	logInfo "Creating Davinci shortcut"
	$WshShell = New-Object -COMObject WScript.Shell
	$Shortcut = $WshShell.CreateShortcut("C:\Users\Public\Desktop\DaVinci Resolve.lnk")
	$Shortcut.TargetPath = "C:\Program Files\Blackmagic Design\DaVinci Resolve\Resolve.exe"
	$Shortcut.Save()
}
catch{
	logError "An installation error was detected! Check install args, integrity and availability."
	exit 1
}
exit 0

