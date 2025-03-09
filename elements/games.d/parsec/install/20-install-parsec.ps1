Start-Process -Wait -FilePath "C:\tools\parsec-windows.exe" -ArgumentList "/silent /norun /percomputer /vdd"

$wshShellObj = New-Object -ComObject WScript.Shell
$shortcutPath = "C:\Users\Public\Desktop\Parsec.lnk"
$targetPath = "C:\Program Files\Parsec\parsecd.exe"
$workdir = "C:\Program Files\Parsec"
$shortcut = $wshShellObj.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.WorkingDirectory = $workdir
$shortcut.Save()

#"Run as User" checkbox enable 
$bytes = [System.IO.File]::ReadAllBytes("C:\Users\Public\Desktop\Parsec.lnk")
$bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
[System.IO.File]::WriteAllBytes("C:\Users\Public\Desktop\Parsec.lnk", $bytes)