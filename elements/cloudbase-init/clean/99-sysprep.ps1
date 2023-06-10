Start-Sleep -Seconds 60.0
cmd.exe /c net user Administrator /active:no
cmd.exe /c net user Администратор /active:no
cmd.exe /c c:\windows\system32\sysprep\sysprep.exe /oobe /generalize /quit /unattend:c:\progra~1\cloudb~1\cloudb~1\conf\Unattend.xml
exit
