#Import modules
Import-Module Msonline
Import-Module AzureAD
#Log in to tenant
$UserCredential = Get-Credential -Username pmorgan-a@corp.ad.tullib.com -Message "Exchange Online"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $UserCredential 
Connect-AzureAD -Credential $UserCredential

#Queries for hybrid synced users
Get-AzureADUser -All $true | Where-Object {$_.DirSyncEnabled -ne $true}
Get-AzureADUser -All $true | Where-Object {($_.DirSyncEnabled -ne $true) -and ($_.usertype -eq "Member")}

#Shit attempts for the above
Get-MsolUser -Synchronized
Get-AzureADUser -ObjectId peter.morgan@tpicap.com | Format-List #| Select-Object -ExpandProperty ExtensionProperty, source
(Get-ADUser [guid][system.convert]::frombase64string((Get-MsolUser -UserPrincipalName peter.morgan@tpicap.com).ImmutableID)).Guid

#UPN fix when recipient can't be found error, due to blank UPN
Set-MsolUserPrincipalName -UserPrincipalName Gordon.Robb@icap.com -NewUserPrincipalName Gordon.Robb@tpicap365.mail.onmicrosoft.com

# Get AADConnect DirSync users, and non-dirsync users
Get-AzureADUser | Where {$_.DirSyncEnabled -eq $true} #DirSync
Get-AzureADUser | Where {$_.DirSyncEnabled -eq $null} #Non-dirsync

#Get all users to csv from AzureAD
connect-msolservice
Get-MsolUser -All |
select UserPrincipalName, IsLicensed, ObjectId, ImmutableId, WhenCreated,
    MSExchRecipientTypeDetails, CloudExchangeRecipientDisplayType, LastDirSyncTime | 
Export-csv C:\temp\o365users.csv -NTI

#Get-AzureADUser -ObjectId "peter.morgan@tpicap.com" | fl
#select UserPrincipalName, ObjectId, ImmutableId, WhenCreated,
#    MSExchRecipientTypeDetails,CloudExchangeRecipientDisplayType,DirSyncProvisioningErrors,
#    IsLicensed,LastDirSyncTime | 

#DirSyncEnabled,OnPremisesSecurityIdentifier

(Get-MsolUser -UserPrincipalName peter.morgan@tpicap.com).Licenses.AccountSkuId