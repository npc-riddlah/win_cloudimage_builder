cmd.exe /c "echo y | chkdsk C: /F"
Remove-Item C:\hooks\preinstall\05-chkdsk.ps1 -Force
exit
