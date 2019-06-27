Import-Module Msonline
$UserCredential = Get-Credential -Username pmorgan-a@corp.ad.tullib.com -Message "Exchange Online"
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $UserCredential 

get-mailbox -ResultSize Unlimited | where {$_.emailaddresses -like "*btec.com"}

#Switch litigation hold on for all mailboxes
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox"} | Set-Mailbox -LitigationHoldEnabled $true 

#To see inbox rules
Get-InboxRule -Mailbox JGranville

#Switch litigation hold on for mailboxes that have it switched off
Get-Mailbox -ResultSize Unlimited -Filter {RecipientTypeDetails -eq "UserMailbox" -and LitigationHoldEnabled -eq "False"} | Set-Mailbox -LitigationHoldEnabled $true 

#Get mailboxes and there audit status
Get-mailbox -ResultSize Unlimited | select UserPrincipalName, auditenabled, AuditDelegate, AuditAdmin | Export-CSV C:\temp\mailbox_audit.csv -NT
Get-mailbox -Identity JGranville | select UserPrincipalName, auditenabled, AuditDelegate, AuditAdmin

#Create new shared mailbox
New-Mailbox -Name "ICAP Equity Brokerage" -Alias "ICAPEquityBrokerage" -OrganizationalUnit "uk.icap.com/Process Mailboxes" -Database "UK0_UserStore01" -UserPrincipalName  ICAPEquityBrokerage@icap.com -Shared

#Get mailbox SMTP addresses
get-mailbox -ResultSize Unlimited | Select DisplayName, UserPrincipalName, PrimarySMTPAddress | export-CSV C:\temp\O365mailboxes.csv -NTI

#Change a mailboc to be ACLableRemoteMailbox
Get-AdUser sara.scott@tpicap.com | Set-AdObject -Replace @{msExchRecipientDisplayType=-1073741818}

#Get calendar permissions for a mailbox
Get-MailboxFolderPermission Andrew.Polydor@tpicap.com:\Calendar
Get-MailboxFolderPermission Matthew.Forsyth@tpicap.com:\Calendar

#Add\Set\Remove calendar permissions for a mailbox
Remove-MailboxFolderPermission -Identity Andrew.Polydor@tpicap.com:\Calendar -User sara.scott@tpicap.com
Add-MailboxFolderPermission -Identity Andrew.Polydor@tpicap.com:\Calendar -User sara.scott@tpicap.com -AccessRights Editor
Add-MailboxFolderPermission -Identity Matthew.Forsyth@tpicap.com:\Calendar -User sara.scott@tpicap.com -AccessRights Editor
Set-MailboxFolderPermission -Identity Matthew.Forsyth@tpicap.com:\Calendar -User sara.scott@tpicap.com -AccessRights Editor

# Get all contacts and if they are members of groups.
$SearchBase = "DC=sg,DC=icap,DC=com"
$ADServer = "SGADSRV02.sg.icap.com"
$GetAdminact = get-credential
$filepath = "C:\temp\DGRecurse\sg.icap_contacts.csv"
Get-ADobject -server $ADServer -Credential $GetAdminact -searchbase $SearchBase -LDAPfilter "objectClass=contact" -Properties Memberof,TargetAddress | Where-object {$_.memberof -ne $null} | Select-Object name,TargetAddress, @{Name="GroupNames";Expression={$_.memberof}} | export-csv $filepath -NTI