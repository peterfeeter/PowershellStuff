#ADQuery to get empty distribution lists - need to be run on a per domain basis to get forest wide - worked perfectly and includes all group types
Get-ADGroup -LDAPFilter "(&(objectClass=group)(mail=*))" -SearchBase "DC=uk,DC=icap,DC=com" -Properties Members | Where-Object {$_.Members.Count -eq 0} | select-object Name, GroupCategory,GroupScope,DistinguishedName | export-csv D:\Output\empty-DGs-uk.csv -NTI
Get-ADGroup -LDAPFilter "(&(objectClass=group)(mail=*))" -Server "BR00WDSSAPP01P.br.icap.com" -SearchBase "DC=br,DC=icap,DC=com" -Properties Members | Where-Object {$_.Members.Count -eq 0} | select-object Name, GroupCategory,GroupScope,DistinguishedName | export-csv D:\Output\empty-DGs.csv -NTI
Get-ADGroup -LDAPFilter "(&(objectClass=group)(mail=*))" -Server "SGADSRV04.sg.icap.com" -SearchBase "DC=sg,DC=icap,DC=com" -Properties Members | Where-Object {$_.Members.Count -eq 0} | select-object Name, GroupCategory,GroupScope,DistinguishedName | export-csv D:\Output\empty-DGs-sg.csv -NTI
Get-ADGroup -LDAPFilter "(&(objectClass=group)(mail=*))" -Server "AUICAPAD07.au.icap.com" -SearchBase "DC=au,DC=icap,DC=com" -Properties Members | Where-Object {$_.Members.Count -eq 0} | select-object Name, GroupCategory,GroupScope,DistinguishedName | export-csv D:\Output\empty-DGs-au.csv -NTI
Get-ADGroup -LDAPFilter "(&(objectClass=group)(mail=*))" -Server "GB00WDSSAPP03P.global.icap.com" -SearchBase "DC=global,DC=icap,DC=com" -Properties Members | Where-Object {$_.Members.Count -eq 0} | select-object Name, GroupCategory,GroupScope,DistinguishedName | export-csv D:\Output\empty-DGs-glob.csv -NTI
Get-ADGroup -LDAPFilter "(&(objectClass=group)(mail=*))" -Server "HKICAPAD01.hk.icap.com" -SearchBase "DC=hk,DC=icap,DC=com" -Properties Members | Where-Object {$_.Members.Count -eq 0} | select-object Name, GroupCategory,GroupScope,DistinguishedName | export-csv D:\Output\empty-DGs-hk.csv -NTI
Get-ADGroup -LDAPFilter "(&(objectClass=group)(mail=*))" -Server "uk0wdssapp01p.icap.com" -SearchBase "DC=icap,DC=com" -Properties Members | Where-Object {$_.Members.Count -eq 0} | select-object Name, GroupCategory,GroupScope,DistinguishedName | export-csv D:\Output\empty-DGs-icap.csv -NTI
Get-ADGroup -LDAPFilter "(&(objectClass=group)(mail=*))" -Server "JPICAPAD01.jpn.icap.com" -SearchBase "DC=jpn,DC=icap,DC=com" -Properties Members | Where-Object {$_.Members.Count -eq 0} | select-object Name, GroupCategory,GroupScope,DistinguishedName | export-csv D:\Output\empty-DGs-jpn.csv -NTI
Get-ADGroup -LDAPFilter "(&(objectClass=group)(mail=*))" -Server "USICAPDCS03.us.icap.com" -SearchBase "DC=us,DC=icap,DC=com" -Properties Members | Where-Object {$_.Members.Count -eq 0} | select-object Name, GroupCategory,GroupScope,DistinguishedName | export-csv D:\Output\empty-DGs-us.csv -NTI

#Other attempts below that didn't work so well
#ExchangeQuery to get all mail enabled groups forestwide
Set-ADServerSettings -ViewEntireForest $true
get-distributiongroup -ResultSize Unlimited | Where-Object {$_.RecipientType -like "mail*"} | Select-Object DisplayName, PrimarySmtpAddress, DistinguishedName, RecipientTypeDetails, HiddenFromAddressListsEnabled, RequireSenderAuthenticationEnabled | Export-CSV D:\temp\Scripts\PM\allDLs1.csv -NTI

#ExchangeQuery to get empty distribution groups, but it didn't work well.
$DistributionGroups = Get-DistributionGroup -Resultsize Unlimited
$DistributionGroups | Where-Object {!(Get-DistributionGroupMember $_)} | Select-Object Name | Export-Csv C:\Temp\EmptyDLs.csv

#Queries to get all members of distribution lists
#1 - didn't try it
$saveto = "C:\\listmembers.txt"

Get-DistributionGroup | Sort-Object name | ForEach-Object {

	"`r`n$($_.Name)`r`n=============" | Add-Content $saveto
	Get-DistributionGroupMember $_ | Sort-Object Name | ForEach-Object {
		If($_.RecipientType -eq "UserMailbox")
			{
				$_.Name + " (" + $_.PrimarySMTPAddress + ")" | Add-Content $saveto
			}
	}
}

#2 - to get all PF group members, didn't work well though.
$saveto = "D:\Temp\Scripts\PM\PF_DGmembers.csv" 

Get-DistributionGroup -OrganizationalUnit "uk.icap.com/PublicFolderSecurityGroups" -Resultsize Unlimited | Sort-Object Name | ForEach-Object {
     "`r`n$($_.Name + "," + $_.PrimarySMTPAddress)`r`n" | Add-Content $saveto 
     Get-DistributionGroupMember $_.Name | Sort-Object Name | ForEach-Object {
		  ",," + $_.DisplayName + "," + $_.PrimarySMTPAddress + "," + $_.RecipientType| Add-Content $saveto } }


Get-DistributionGroup "tpicap global it" | Get-DistributionGroupMember "tpicap global it" | where {$_.primarysmtpaddress -like $null} | select primary*, displayname 

Get-DistributionGroupMember "tpicap global it" | select name,primary*,department,company,CountryOrRegion | export-csv C:\temp\tpicapglobalit.csv -NTI
 
get-content C:\temp\icapITpeople.txt | ForEach-Object {Get-Recipient $_}

# Get all contacts and if they are members of groups.
$SearchBase = "DC=sg,DC=icap,DC=com"
$ADServer = "SGADSRV02.sg.icap.com"
$GetAdminact = get-credential
$filepath = "C:\temp\DGRecurse\sg.icap_contacts.csv"
Get-ADobject -server $ADServer -Credential $GetAdminact -searchbase $SearchBase -LDAPfilter "objectClass=contact" -Properties Memberof,TargetAddress | Where-object {$_.memberof -ne $null} | Select-Object name,TargetAddress, @{Name="GroupNames";Expression={$_.memberof}} | export-csv $filepath -NTI

# Count members of a group
Get-ADGroupMember -Server "UK0WDSSAPP04P.uk.icap.com" -Identity "CN=Contacts,OU=Misc,OU=External Recipients,DC=uk,DC=icap,DC=com"
