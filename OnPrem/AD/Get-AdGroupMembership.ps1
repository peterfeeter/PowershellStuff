#Query AD for group membership and send to csv
Get-ADGroupMember Global_G_Blackberry_BYOD_Users | Select-Object Name, SamAccountName | Export-CSV C:\Temp\TPREports\Global_G_Blackberry_BYOD_Users.csv -NTI

#Get ad user info for all users who are members of a group
Get-ADGroupMember Global_G_Blackberry_BYOD_Users -Recursive | 
Get-ADUser -Properties * | 
Select-Object cn, surname, givenname, enabled, co, UserPrincipalName, EmailAddress | Export-Csv "C:\temp\20181008_membersoftechadmin.csv" -NoTypeInformation

#Get count of members of a group CORP
$group = Get-ADGroupMember "TP ICAP global staff" -Recursive 
$group.count

#Get count of members of a group GLOBAL
$group = Get-ADGroupMember -Server GB00WDSSAPP03P.global.icap.com "Domain Admins" -Recursive | select Name,SamAccountName
$group.count

#Get count of large groups, does not recurse tho
$ADInfo = Get-ADGroup -Server LDNPINFDCE01.eur.ad.tullib.com -Identity "TP ICAP global staff" -Properties Members
$ADInfo.count

#Get group then get members email addresses, and then go get there details and store in tab delimited text file
$cred = Get-Credential
Get-ADGroupMember -Credential $cred -Server "SNGPINFDCA04.apac.ad.tullib.com" "Global_G_Riskonnect_Okta" | 
Select-Object samaccountname | 
ForEach-Object{Get-ADUser -Credential $cred -Server "SNGPINFDCA04.apac.ad.tullib.com" $_.samaccountname -Properties GivenName, Surname, mail} | 
ForEach-Object{write-output "$($_.samaccountname) `t $($_.GivenName) `t $($_.Surname) `t $($_.mail)"} |
Out-File C:\temp\Riskonnect_APAC_20190304.txt

Get-ADGroup -Server GB00WDSSAPP03P.global.icap.com "TP ICAP global staff" | fl

Get-MsolUser -Synchronized | fk