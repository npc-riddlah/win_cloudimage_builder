cd "C:\hooks\install\"
for /r %%v in (*.cmd) do start /wait %%v
cd "C:\hooks\configure\"
for /r %%v in (*.cmd) do start /wait %%v
cd "C:\hooks\clean\"
for /r %%v in (*.cmd) do start /wait %%v
del "C:\hooks\*" /f /q /s
shutdown /s /t 10
rmdir "C:\hooks\" /s /q 
del "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\mainhook.cmd" /f /q /s
exit