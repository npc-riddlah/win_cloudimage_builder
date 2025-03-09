############
#All of this code needs to install blender from winget, but sysprep failings to error when winget apps installed.
############

#Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
#winget install blender -s msstore --accept-package-agreements  --accept-source-agreements

#$pakBlender = Get-AppxPackage | Where-Object {$_.Name -Like "*blender*" } 
#$pakBlender = $pakBlender.PackageFamilyName
#$WshShell = New-Object -COMObject WScript.Shell
#$Shortcut = $WshShell.CreateShortcut("$home\Desktop\Blender.lnk")
#$Shortcut.TargetPath = "shell:AppsFolder\"+$pakBlender+"!BLENDER"
#$Shortcut.Save()

Start-Process -Wait -FilePath C:/tools/blender.msi -ArgumentList "/qn /norestart ALLUSERS=2"
Remove-Item -Force -Path $PSCommandPath

exit
