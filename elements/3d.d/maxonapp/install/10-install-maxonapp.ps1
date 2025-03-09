Start-Process -Wait -FilePath C:/tools/Maxon_App_2025.1.0_Win.exe -ArgumentList "--mode unattended --unattendedmodeui none"
Remove-Item -Force -Path $PSCommandPath

exit
