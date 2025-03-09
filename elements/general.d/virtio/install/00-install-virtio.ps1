${function:logInfo} = ${using:function:logInfo}
logInfo "Virtio driver installation begins."

Get-ChildItem "C:\drv\virtio" -Recurse -Filter "*.inf" | Where-Object -Property FullName -like "*2k22*" | Where-Object -Property FullName -like "*amd64*" | ForEach-Object {
	logInfo "Installing $_.FullName"
	$certfile = $_.FullName -replace '.inf','.cat'
	$signature = Get-AuthenticodeSignature $certfile
	$store = Get-Item -Path Cert:\LocalMachine\TrustedPublisher
	$store.Open("ReadWrite")
	$store.Add($signature.SignerCertificate)
	$store.Add($signature.SignerCertificate)
	PNPUtil.exe /add-driver  $_.FullName /install
}
Remove-Item -Force -Path $PSCommandPath
logInfo "Virtio drivers installed!"
exit
