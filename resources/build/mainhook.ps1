#This script will run in audit mode after every reboot before he is removes himself from autostart.
#It will install all of the provided elements data

#Preinstall what we need and preconf

function logInfo() {
	filter timestamp {"$(Get-Date -Format o): $_"}
	$timestamp = timestamp
	$text = "$timestamp [INFO] $args"
	Write-Host $text
	#Open Serial to write Log
	$port = new-Object System.IO.Ports.SerialPort COM1,115200,None,8,one 

	$port.open()
	$port.Write($text)
	$port.Write([System.Text.Encoding]::UTF8.GetString(0x0D))
	$port.Write([System.Text.Encoding]::UTF8.GetString(0x0A))
	$port.close()
}

function logError() {
	filter timestamp {"$(Get-Date -Format o): $_"}
	$timestamp = timestamp
	$text = "$timestamp [ERROR] $args"
	Write-Host $text
	#Open Serial to write Log
	$port = new-Object System.IO.Ports.SerialPort COM1,115200,None,8,one 

	$port.open()
	$port.Write($text)
	$port.Write([System.Text.Encoding]::UTF8.GetString(0x0D))
	$port.Write([System.Text.Encoding]::UTF8.GetString(0x0A))
	$port.close()
}

function checkReboot {
	Test-PendingReboot -Detailed
	if ( (Test-PendingReboot).IsRebootPending )
	{
		logInfo "Windows Wants Reboot - rebooting now"
        Restart-Computer
        Stop-Process -Name "cmd" -Force
		Stop-Process -Name "powershell" -Force
        Start-Sleep -Second 120.0
		exit
	}
}

function prepareSystem {

	logInfo "Booting successfull. Preparing System."
	chcp 65001
	Stop-Process -Name "cloudbase-init" -Force
	$ProgressPreference = 'SilentlyContinue'

	#Install WinGet
	logInfo "Installing WinGet"
	if (Get-Command winget -ErrorAction SilentlyContinue) {
		Write-Host "Winget already installed. Skiping."
	} else {
		logInfo "Winget not found. Proceeding install..."
	        Invoke-WebRequest -Uri 'https://aka.ms/getwinget' -OutFile %TEMP%\winget.msixbundle
		Invoke-WebRequest -Uri 'https://github.com/microsoft/winget-cli/releases/download/v1.10.340/4df037184d634a28b13051a797a25a16_License1.xml' -OutFile %TEMP%\winget-license.xml
		Add-AppxProvisionedPackage -Online -PackagePath %TEMP%\winget.msixbundle -Regions All -LicensePath %TEMP%\winget-license.xml
		Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
	}

	#Disable sleep and hybernation
	logInfo "Disabling sleep and hybernation"
	reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /t REG_DWORD /v "IRPStackSize" /d 32 /f
	powercfg -h off
	powercfg -change -monitor-timeout-ac 0

	#Disable password expiration
	logInfo "Disable password expiration"
	net accounts /maxpwage:unlimited
	
	#Install NuGet and PSWindowsUpdate
	logInfo "Installing dependency tools"
	Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -force
	Install-Module -Name PendingReboot -force
	Install-Module -Name PSWindowsUpdate -force
	#Install-WindowsFeature GPMC -IncludeManagementTools
	
	#Disabling User Lockout due several failure logins
	logInfo "Disabling User Lockout due several failure Logins"
	secedit /export /cfg c:\secpol.cfg
	(Get-Content c:\secpol.cfg).replace("LockoutBadCount = 10","LockoutBadCount = 0") | Set-Content c:\secpol.cfg
	secedit /configure /db c:\windows\security\local.sdb /cfg c:\secpol.cfg /areas SECURITYPOLICY
	Remove-Item -Force -Path "c:\secpol.cfg"
}

#Check and install updates
function checkUpdates {
	logInfo "Checking and installing updates. It will takes a while..."
	Install-WindowsUpdate -AcceptAll -AutoReboot
}

#Installing drivers and driver certs. Then removing folder
function installDrivers ($path_drv="C:\drivers",$filter="*") {
	logInfo "Looking drivers in path: $path_drv"
	if (!(Test-Path $path_drv)) { 
		logInfo "Drivers not found"
		return 
	}
	logInfo "Installing drivers:"
	Get-ChildItem $path_drv -Recurse -Filter "*.inf" | Where-Object -Property FullName -like $filter | ForEach-Object {
		logInfo $_.FullName
		$certfile = $_.FullName -replace '.inf','.cat'
		$signature = Get-AuthenticodeSignature $certfile
		$store = Get-Item -Path Cert:\LocalMachine\TrustedPublisher
		$store.Open("ReadWrite")
		$store.Add($signature.SignerCertificate)
		PNPUtil.exe /add-driver  $_.FullName /install
	}
	Remove-Item -Recurse -Force -Path $path_drv
}

#Running hooks and cleaning by stage
function runHooksAndCleanDir ($path_hooks="C:\hooks\") {
	logInfo "======================"
	logInfo "New stage: $path_hooks"
	logInfo "======================"
	Get-ChildItem $path_hooks | ForEach-Object {
		logInfo $_.FullName
		& $_.FullName
		Remove-Item -Recurse -Force -Path $_.FullName
	}
	Remove-Item -Recurse -Force -Path $path_hooks
}

function installHooks {
	logInfo "============="
	logInfo "Running hooks"
	logInfo "============="
	runHooksAndCleanDir('C:\hooks\preinstall')
	runHooksAndCleanDir('C:\hooks\install')
	runHooksAndCleanDir('C:\hooks\configure')	
	Stop-Process -Name "sysprep" -Force #Thats we need in Windows Audit Mode (sysprep autostarts after reboot)
	checkReboot
	runHooksAndCleanDir('C:\hooks\clean')
}

#Cleaning mainhook data
function cleanAll {
	logInfo "Final cleaning and shutdown"
	#Disabling any autologin
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v ForceAutoLogon /f
	reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultDomainName /f
	reg delete "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "mainhook" /f
	#Removing all the service folders
	Remove-Item -Recurse -Force -Path "C:\hooks"
	Remove-Item -Recurse -Force -Path "C:\tools"
	Remove-Item -Recurse -Force -Path "C:\drv"
	Remove-Item -Recurse -Force -Path "C:\conf"
	Remove-Item -Recurse -Force -Path "C:\conf-en"
	Remove-Item -Recurse -Force -Path "C:\config"
	Remove-Item -Force -Path "C:\mainhook.ps1"
}


#Running circles...
prepareSystem
checkUpdates
installDrivers
installHooks
cleanAll
shutdown /s /t 10
logInfo "Done! Shutting down in 10 secs"
exit
