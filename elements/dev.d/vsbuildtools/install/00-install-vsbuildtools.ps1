logInfo "Installing vsbuildtools..."
winget install --id=Microsoft.VisualStudio.2022.BuildTools  -e --custom "--add Microsoft.Component.MSBuild --add Microsoft.VisualStudio.Component.Roslyn.Compiler --add Microsoft.VisualStudio.Component.TextTemplating --add Microsoft.VisualStudio.Component.VC.CoreIde --add Microsoft.VisualStudio.Component.VC.Redist.14.Latest --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Core --add Microsoft.VisualStudio.Component.VC.ASAN --add Microsoft.VisualStudio.Component.VC.ATL --add Microsoft.VisualStudio.Component.VC.CMake.Project --add Microsoft.VisualStudio.Component.VC.DiagnosticTools --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.VC.140 --add Microsoft.VisualStudio.Component.VC.ATLMFC --add Microsoft.VisualStudio.Component.VC.CLI.Support --add Microsoft.VisualStudio.Component.VC.Llvm.Clang --add Microsoft.VisualStudio.Component.VC.Llvm.ClangToolset --add Microsoft.VisualStudio.Component.VC.Modules.x86.x64 --add Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Llvm.Clang --add Microsoft.VisualStudio.ComponentGroup.VC.Tools.142.x86.x64 --add Microsoft.VisualStudio.Component.Windows11SDK.26100" --accept-package-agreements --accept-source-agreements

#Updating envvars
foreach($level in "Machine","User") {
   [Environment]::GetEnvironmentVariables($level)
}
