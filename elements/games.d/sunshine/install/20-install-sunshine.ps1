Start-Process -Wait -FilePath "C:\tools\sunshine-windows-installer.exe" -ArgumentList "/S /AllUsers /ALLUSERS=1"

$wshShellObj = New-Object -ComObject WScript.Shell
$shortcutPath = "C:\Users\Public\Desktop\Sunshine.lnk"
$targetPath = "C:\Program Files\Sunshine\sunshine.exe"
$workdir = "C:\Program Files\Sunshine"
$shortcut = $wshShellObj.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.WorkingDirectory = $workdir
$shortcut.Arguments = "--shortcut"
$shortcut.Save()

#"Run as User" checkbox enable 
$bytes = [System.IO.File]::ReadAllBytes("C:\Users\Public\Desktop\Sunshine.lnk")
$bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
[System.IO.File]::WriteAllBytes("C:\Users\Public\Desktop\Sunshine.lnk", $bytes)