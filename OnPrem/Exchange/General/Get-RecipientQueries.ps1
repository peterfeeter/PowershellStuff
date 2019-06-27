Set-ADServerSettings -ViewEntireForest $true
Get-Recipient -ResultSize Unlimited -Filter {Name -like "*tpmatch*"}


