#Get all errors
Get-MsolDirSyncProvisioningError -ErrorCategory PropertyConflict | select DisplayName,ObjectType, ProvisioningErrors, proxyAddresses, UserPrincipalName | Export-Csv C:\temp\AADCSyncConflicts.csv -NTI


Get-MsolDirSyncFeatures -Feature DuplicateProxyAddressResiliency


Get-MsolUser -HasErrorsOnly