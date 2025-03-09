logInfo "Installing VCRedist"
Get-ChildItem "C:\tools\vcredist\" -Recurse -Filter "*.inf" | ForEach-Object {
		logInfo $_.FullName
		Start-Process -Wait -FilePath $_.FullName -ArgumentList "/quiet /install /norestart"
	}