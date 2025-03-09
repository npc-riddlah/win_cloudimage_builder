logInfo "Installing python..."
winget install python.python.3.10 python.python.3.12 --accept-package-agreements --accept-source-agreements

python -m pip install virtualenv

#Updating envvars
foreach($level in "Machine","User") {
   [Environment]::GetEnvironmentVariables($level)
}
