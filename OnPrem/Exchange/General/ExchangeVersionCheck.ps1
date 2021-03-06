Add-PSSnapIn Microsoft.Exchange.Management.PowerShell.E2010

$ExchangeServers = Get-ExchangeServer | where {$_.ServerRole -ne "edge"} | Sort-Object Name

ForEach  ($Server in $ExchangeServers) 
{

Invoke-Command -ComputerName $Server.Name -ScriptBlock {Get-Command  Exsetup.exe | ForEach-Object {$_.FileversionInfo}}

}
