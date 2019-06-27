#It's a query similar to Get-EASDeviceReport.ps1
Set-ADServerSettings -ViewEntireForest $true
Get-ActiveSyncDevice | 
Get-ActiveSyncDeviceStatistics | Select-Object Identity, DeviceId, DeviceOS, DeviceType, DeviceUserAgent, DeviceModel,LastSuccessSync | Export-CSV C:\temp\AS_Report4.csv -Nti

$mbx = Get-CASMailbox tbovitz | Where-Object { $_.ActiveSyncEnabled -eq $true }
Get-ActiveSyncDeviceStatistics -Mailbox $mbx.PrimarySMTPAddress.ToString() | Select-Object Identity, GUID, LastSuccessSync

Get-ActiveSyncDevice

#Get active sync devices that checked in the last year and put it fancy outgrid
Get-ActiveSyncDevice -ResultSize unlimited | Get-ActiveSyncDeviceStatistics | where {$_.LastSyncAttemptTime -lt (get-date).adddays(-90)} | out-gridview