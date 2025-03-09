#Todo: REAL silent install

Start-Process -Wait -FilePath C:/tools/maya/Setup.exe -ArgumentList "-q"
Remove-Item -Force -Path $PSCommandPath

exit
