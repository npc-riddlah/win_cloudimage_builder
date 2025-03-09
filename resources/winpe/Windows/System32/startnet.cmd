wpeinit

diskpart /s X:/diskpart_assign.txt
bcdboot C:\Windows\ /s E: /f ALL
bootsect /nt60 all /force

cd X:/hooks/
dir
for /r "." %%a in (*.bat) do call "%%a"

wpeutil shutdown