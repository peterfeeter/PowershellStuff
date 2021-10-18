Start-Transcript -Path (Join-Path "C:\Program Files (x86)\ICAP\BLOX\Logs" "$($MyInvocation.MyCommand.Name).log") -Append:$true

$CommonCodeScriptPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "Common.ps1"
. $CommonCodeScriptPath

UpdateUiSubTask "Downloading required DSC modules..."
UpdateUiSubTask "Copying DSC modules to C:\Program Files\WindowsPowerShell\Modules..."

Copy-Item  -Path  "S:\Applications\DscModules\*" -Destination "C:\Program Files\WindowsPowerShell\Modules" -Recurse -Force -Confirm:$false -Verbose

Stop-Transcript
if ($Error) {exit -1} else {exit 0}