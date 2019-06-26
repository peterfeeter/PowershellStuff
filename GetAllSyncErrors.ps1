#Connect as tenant admin
Connect-MsolService
$syncerrors = Get-MsolDirSyncProvisioningError 
$syncerrors.count