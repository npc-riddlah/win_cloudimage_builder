Start-Process -Wait -FilePath C:/tools/redshift_v2025.1.1_setup.exe -ArgumentList "--mode unattended --unattendedmodeui none /S"
Remove-Item -Force -Path $PSCommandPath
exit
