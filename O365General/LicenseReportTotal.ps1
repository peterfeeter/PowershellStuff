#Con
Connect-AzureAD
$E3 = Get-AzureADSubscribedSku | Where-Object {$_.SkuPartNumber -eq "ENTERPRISEPACK"} | Select -Property Sku*,ConsumedUnits -ExpandProperty PrepaidUnits
$E3TotalFree = ($E3.Enabled - $E3.ConsumedUnits)
$E3TotalFree