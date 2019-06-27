###Documentation of existing configuration
###Get DL members
Get-DistributionGroup TPMatchInbox@tullettprebon.com | Select SamAccountName
Get-DistributionGroupMember aud@tpmatch.com | Select Name,Alias, RecipientType

Get-ADGroup -Server "LDNPINFDCE01.eur.ad.tullib.com" -Identity "tpMATCH Senders"
Get-ADGroupMember -Server "LDNPINFDCE01.eur.ad.tullib.com" -Identity "tpicapMatchbook SalesMailbox FullAccess" | select SamAccountName
Get-ADPermission | where-object {($_.InheritanceType -like "None") -and ($_.AccessRights -like "*ExtendedRight*") -and ($_.User -notlike "S-1-*")}
###Get Send permission on a distribution group
Get-ADPermission -Identity "LatamNDF tpMatch Clients" -DomainController "LDNPINFDCE01.eur.ad.tullib.com" | where-object {($_.IsInherited -like "False") -and ($_.User -notlike "S-1-*")} | select User, AccessRights | ft -auto

###Get publicfolder info
Get-PublicFolder "\Global Folders\UAT TPMatch Inbox" | fl 
Get-MailPublicFolder "tpMatch-Inbox@tullettprebon.com" | fl
Get-MailPublicFolder "\Global Folders\UAT TPMatch NDF Inbox" | select Name, PrimarySmtpAddress
Get-PublicFolderStatistics -ResultSize Unlimited| Select-Object @{Expression={$_.FolderPath};Label="FolderPath";}, @{Expression={$_.AdminDisplayName};Label="AdminDisplayName";}, @{Expression={$_.LastAccessTime};Label="LastAccessTime";}, @{Expression={$_.LastModificationTime};Label="LastModificationTime";}, @{Expression={$_.LastUserAccessTime};Label="LastUserAccessTime";},@{name="TotalItemSize (MB)"; expression={[math]::Round(($_.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}} | Sort-Object TotalItemSize | Export-CSV C:\temp\pubfol.csv -NTI
Get-PublicFolderClientPermission "\Global Folders\UAT TPMatch NDF Inbox\UAT TPMatch NDF Sent" | where {$_.user -notlike "NT User:S-1-*"} | select user, accessrights
Get-PublicFolderClientPermission "\Global Folders\UAT TPMatch NDF Inbox" | where {$_.user -notlike "NT User:S-1-*"} | select user

###Get Mailbox settings
Get-Mailbox TPMatch-Inbox@tullettprebon.com | select SamAccountName
Get-MailboxStatistics tpMatchInbox | fl
#Get Mailbox permissions
Get-MailboxPermission tpMatchInbox | where-object {($_.IsInherited -like "False") -and ($_.User -notlike "S-1-*")} | select User, AccessRights | ft -auto
Get-MailboxPermission TPMatchNDF | where-object {($_.IsInherited -like "False") -and ($_.User -notlike "S-1-*")} | select User | ft -auto

###Create new for rebrand

#Create new mailbox
New-Mailbox -Name "tpicap Matchbook NDF Backup" -Alias "tpicapMatchbookNDFBackup" -OrganizationalUnit "eur.ad.tullib.com/LDN/ExchangeObjects/tpicapMatchbook" -Database "London1" -UserPrincipalName matchbook-ndf-backup@tpicap.com -Shared
New-Mailbox -Name "tpicap Matchbook NDF" -Alias "tpicapMatchbookNDF" -OrganizationalUnit "eur.ad.tullib.com/LDN/ExchangeObjects/tpicapMatchbook" -Database "London1" -UserPrincipalName matchbook-ndf@tpicap.com -Shared
New-Mailbox -Name "tpicap Matchbook" -Alias "tpicapMatchbook" -OrganizationalUnit "eur.ad.tullib.com/LDN/ExchangeObjects/tpicapMatchbook" -Database "London1" -UserPrincipalName matchbook@tpicap.com -Shared
New-Mailbox -Name "tpicap Matchbook Backup" -Alias "tpicapMatchbookBackup" -OrganizationalUnit "eur.ad.tullib.com/LDN/ExchangeObjects/tpicapMatchbook" -Database "London1" -UserPrincipalName matchbook-backup@tpicap.com -Shared
#Create new distribution groups
$DLalias = "SGDtpicapMatchbook"
$DLname = "SGD tpicapMatchbook"
$DLaddress = "sgd@tpicapmatchbook.com"
New-DistributionGroup -DomainController "LDNPINFDCE01.eur.ad.tullib.com" -OrganizationalUnit "eur.ad.tullib.com/LDN/ExchangeObjects/tpicapMatchbook/Rates" -Alias $DLalias -Name $DLname -PrimarySmtpAddress $DLaddress -Type Distribution -Members tpicapMatchbookNDFBackup, tpicapMatchbookNDF

Get-DistributionGroup "UATtpicapMatchbookEURClients" | fl

Get-MailboxPermission -Identity matchbook@tpicap.com

#Add full access permissions to new mailbox
$Members = Get-Content C:\temp\tpicapmatchbooktesters.txt
foreach ($Member in $Members) {
    #Add-MailboxPermission -Identity matchbook@tpicap.com -User $Member -AccessRights FullAccess
    #Add-MailboxPermission -Identity matchbook-ndf@tpicap.com -User $Member -AccessRights FullAccess 
    Add-MailboxPermission -Identity matchbook-backup@tpicap.com -User $Member -AccessRights FullAccess
    Add-MailboxPermission -Identity matchbook-NDF-backup@tpicap.com -User $Member -AccessRights FullAccess }

#Add send-as permission to distribution groups
$DLname = "SGD tpicapMatchbook"
Get-DistributionGroup “$DLName” | Add-AdPermission –ExtendedRights Send-As –User “tpicapMatchbook SalesMailbox FullAccess” –AccessRights ExtendedRight

#Add read permission to mailbox
Add-MailboxFolderPermission -Identity matchbook-ndf-backup@tpicap.com:\ -User "tpicapMatchbook MarketAdminMailbox ReadAccess" -AccessRights Reviewer
Add-MailboxFolderPermission -Identity matchbook-backup@tpicap.com:\ -User "tpicapMatchbook MarketAdminMailbox ReadAccess" -AccessRights Reviewer

Add-Recipient
get-help Add-MailboxFolderPermission -full