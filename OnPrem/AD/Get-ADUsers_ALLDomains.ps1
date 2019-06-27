# Get all forest users with "domain\samaccountname" format
# Both enabled and disable

$domains = @(Get-ADForest | select -ExpandProperty domains)

$Results = @()
foreach ($domain in $domains)
{
"processing $domain"
$NetbiosName = (Get-ADDomain $domain).netbiosname
$users = $null
$users = Get-ADUser -Server $domain  -Properties Name, DistinguishedName, EmailAddress, Enabled, SamAccountName, UserPrincipalName, CanonicalName -Filter * |  select Enabled, Name, DistinguishedName, EmailAddress, mail, SamAccountName, UserPrincipalName, CanonicalName, @{n='Domain';e={$domain}}, @{n='Netbios';e={$NetbiosName}} , @{N='Domain\username';E={ "$((($_.DistinguishedName -split 'DC=')[1]).Replace(',',''))\$($_.SamAccountName)"}} 
$Results +=  $users
$users | export-csv "c:\Temp\Users_$($domain.Replace('.','-')).csv" -nti
write-host "$($users.count) Users in $domain" 
}
$Results | export-csv "c:\Temp\TPForest.csv" -nti


#Get all disabled users in CORP in certain OUs.
# -SearchBase "OU=EUC,DC=corp,DC=ad,DC=tullib,DC=com"
$users = Import-Csv -Path "C:\temp\DisabledUserCorp.csv" 
ForEach-Object { $UserDN = (Get-ADUser -Identity $_.UserPrincipalName).distinguishedName
Get-ADUser $UserDN -Filter * -Properties title, employeeid, sidhistory, CanonicalName | 
Select-Object SAMAccountName, title, CanonicalName, employeeid,Enabled}

#Get all users from a CSV
$Imported_csv = $Imported_csv = Import-Csv -Path "C:\temp\DisabledGlobalUser.csv" 
$Imported_csv | ForEach-Object { 
    # Retrieve DN of User. 
    $UserDN  = (Get-ADUser -Identity $_.SamAccountName).distinguishedName
    #Remove Deletion Protection from account
    get-aduser $UserDN -Server "GB00WDSSAPP01P.global.icap.com" -Properties title, employeeid, sidhistory, CanonicalName | 
    Select-Object SAMAccountName,  title, CanonicalName, employeeid,@{Name="SIDHistory"; Expression={$_.SIDHistory}} | 
Export-Csv -Path C:\temp\disabledEUC_Global.csv -NoTypeInformation

