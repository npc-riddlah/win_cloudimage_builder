$certfile = 'C:\VirtualDisplayDriver\mttvdd.cat'
$signature = Get-AuthenticodeSignature $certfile
$store = Get-Item -Path Cert:\LocalMachine\TrustedPublisher
$store.Open("ReadWrite")
$store.Add($signature.SignerCertificate)
rundll32.exe advpack.dll,LaunchINFSectionEx C:\VirtualDisplayDriver\MttVDD.inf,MyDevice_Install.NT,,4,N