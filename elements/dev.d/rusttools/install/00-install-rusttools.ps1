logInfo "Installing rust build tools..."

winget install Rustlang.Rustup

#Updating envvars
foreach($level in "Machine","User") {
   [Environment]::GetEnvironmentVariables($level)
}
