echo y | chkdsk C: /F
del /f /q /a  C:\hooks\preinstall\05-chkdsk.cmd & exit
