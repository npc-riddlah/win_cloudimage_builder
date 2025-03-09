#Todo: REAL silent install

Start-Process -Wait -FilePath C:/tools/3dsmax/Setup.exe -ArgumentList "-q"
Remove-Item -Force -Path $PSCommandPath

exit
