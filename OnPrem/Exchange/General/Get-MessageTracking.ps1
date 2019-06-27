#Had real trouble getting these to work remotely, but should work ok on the console of a server

Set-ADServerSettings -ViewEntireForest $true
#Basic commands with start and end date
$StartDate = (Get-Date).AddDays(-30)
$EndDate = Get-Date
Get-TransportServer | Where-Object {$_.Name -like "LDN*"} | Invoke-Command {Get-MessageTrackingLog -Start $StartDate -End $EndDate -Sender "scs@scscommodities.com"} | Select-Object Sender, Recipients, TimeStamp
#or
Get-TransportServer | Invoke-Command {Get-MessageTrackingLog -Start "09/01/2018 09:00:00" -End "10/02/2018 17:00:00" -Sender "Fiona.Hale@icap.com"  -Resultsize unlimited} | Measure-Object


#Advanced commands with fixed date and count
$StartDate = (Get-Date).AddDays(-1)
$EndDate = Get-Date
$msgs = Get-TransportServer | Invoke-Command {Get-MessageTrackingLog -Start $StartDate -End $EndDate -Recipients "fiona.hale@icap.com" -Resultsize unlimited}
$msgs.count

Get-TransportServer | Get-MessageTrackingLog -Start $StartDate -End $EndDate -Sender "Charles.Powers@us.icap.com"-Resultsize unlimited

#Filter transport servers by site with fixed date and count.
$StartDate = (Get-Date).AddDays(-14)
$EndDate = Get-Date
$hubs = Get-ExchangeServer | Where-Object {$_.Name -like "LDN*" -and $_.IsHubTransportServer -eq $true}
foreach ($hub in $hubs) {
    $msgs = Invoke-Command {Get-MessageTrackingLog  Server LDNEXGCAS1 -Start $StartDate -End $EndDate -Sender "scs@scscommodities.com" -Resultsize unlimited}
}

#Single transport server with dates
$StartDate = (Get-Date).AddDays(-14)
$EndDate = Get-Date
Get-MessageTrackingLog -Server LDNEXGCAS4 -Start $StartDate -End $EndDate -Sender "scs@scscommodities.com" -Resultsize unlimited


$msgs = Invoke-Command {Get-MessageTrackingLog -Server $hubs -Start $StartDate -End $EndDate -Sender "fiona.hale@icap.com" -Resultsize unlimited}
$msgs.count