Start-Process -Wait -FilePath C:\tools\Cinema4D_2025_2025.0.2_Win.exe -ArgumentList "--mode unattended --unattendedmodeui none"
Remove-Item -Force -Path $PSCommandPath

$wshShellObj = New-Object -ComObject WScript.Shell
$shortcutPath = "C:\Users\Public\Desktop\Cinema 4D.lnk"
$targetPath = "C:\Program Files\Maxon Cinema 4D 2025\Cinema 4D.exe"
$shortcut = $wshShellObj.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.Save()

exit
