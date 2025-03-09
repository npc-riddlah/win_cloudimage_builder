logInfo "Installing chocolatey package manager"
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
logInfo "Done!"
