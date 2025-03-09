logInfo "Installing git..."
winget install git.git --accept-package-agreements --accept-source-agreements
#Updating envvars
foreach($level in "Machine","User") {
   [Environment]::GetEnvironmentVariables($level)
}
