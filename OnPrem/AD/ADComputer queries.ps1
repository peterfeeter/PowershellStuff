Get-ADComputer -Server "LDNPINFDCG01" -Identity LDN00XW30077 -Properties * | fl

$When = ((Get-Date).AddDays(-14)).Date
Get-ADComputer | Where-Object {$_WhenCreated -ge $When}
Get-ADComputer -identity LDNADROOTDC01 -Properties lastLogonDate | FT Name, LastLogonDate -Autosize


#GetADComputers across forest, did not test
$domains = (Get-ADForest).Domains
$d = [DateTime]::Today.AddDays(-30)
$data = @()
foreach ($domain in $domains)
{
    $data += Get-ADComputer -Server "LDNPINFDCG01" -Identity LDN00XW30077 -Properties PasswordLastSet -Filter {PasswordLastSet -ge $d} -Server $domain -Properties PasswordLastSet,operatingsystem,CanonicalName | select Name,PasswordLastSet,operatingsystem,CanonicalName
}
$data | export-csv c:\temp\computerrecords.csv -NTI


#Get windows 2003 computers from a specified domain DC
$d = [DateTime]::Today.AddDays(-30)
Get-ADComputer -Server SNGPINFDCA03.apac.ad.tullib.com -Filter * -Properties OperatingSystem,LastLogonDate | Where-Object {($_.OperatingSystem -like '*Server*')} | Select-Object Name, LastLogonDate | ft -Autosize

#Get all servers OS from a specified domain DC that have not conntacted in 3 months
$d = [DateTime]::Today.AddDays(-90)
#apac
$allapacserver = Get-ADComputer -Server SNGPINFDCA03.apac.ad.tullib.com -Filter * | fl -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*')} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$allapacserver.Count
$currentapacserver = Get-ADComputer -Server SNGPINFDCA03.apac.ad.tullib.com -Filter * -Properties OperatingSystem,LastLogonDat,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -and ($_.LastLogonDate -gt $d)} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$currentapacserver.Count
#corp
$allcorpserver = Get-ADComputer -Server LDNPINFDCG03.corp.ad.tullib.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*')} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$allcorpserver.Count
$currentcorpserver = Get-ADComputer -Server LDNPINFDCG03.corp.ad.tullib.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -and ($_.LastLogonDate -gt $d)} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$currentcorpserver.Count
#eur
$alleurserver = Get-ADComputer -Server LDNPINFDCE01.eur.ad.tullib.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*')} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$alleurserver.Count
$currenteurserver = Get-ADComputer -Server LDNPINFDCE01.eur.ad.tullib.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -and ($_.LastLogonDate -gt $d)} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$currenteurserver.Count
#na
$allnaserver = Get-ADComputer -Server NJCPINFDCN02.na.ad.tullib.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*')} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$allnaserver.Count
$currentnaserver = Get-ADComputer -Server NJCPINFDCN02.na.ad.tullib.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -and ($_.LastLogonDate -gt $d)} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$currentnaserver.Count

#ICAP.com now
$allglobalserver = Get-ADComputer -Server GB00WDSSAPP03P.global.icap.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*')} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$allglobalserver.Count
$currentglobalserver = Get-ADComputer -Server GB00WDSSAPP03P.global.icap.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -and ($_.LastLogonDate -gt $d)} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$currentglobalserver.Count

$allukserver = Get-ADComputer -Server UK0WDSSAPP04P.uk.icap.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*')} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$allukserver.Count
$currentukserver = Get-ADComputer -Server UK0WDSSAPP04P.uk.icap.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -and ($_.LastLogonDate -gt $d)} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$currentukserver.Count

$allusserver = Get-ADComputer -Server USICAPDCS03.us.icap.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*')} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$allusserver.Count
$currentusserver = Get-ADComputer -Server USICAPDCS03.us.icap.com -Filter * -Properties OperatingSystem,LastLogonDate,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -and ($_.LastLogonDate -gt $d)} | Select-Object Name, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
#$currentusserver.Count

#Export all servers to csv
$allapacserver = Get-ADComputer -Server SNGPINFDCA03.apac.ad.tullib.com -Filter * -Properties Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -or ($_.OperatingSystem -like 'NULL')} | Select-Object Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet 
$allcorpserver = Get-ADComputer -Server LDNPINFDCG03.corp.ad.tullib.com -Filter * -Properties Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -or ($_.OperatingSystem -like 'NULL')} | Select-Object Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
$alleurserver = Get-ADComputer -Server LDNPINFDCE01.eur.ad.tullib.com -Filter * -Properties Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -or ($_.OperatingSystem -like 'NULL')} | Select-Object Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
$allnaserver = Get-ADComputer -Server NJCPINFDCN02.na.ad.tullib.com -Filter * -Properties Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -or ($_.OperatingSystem -like 'NULL')} | Select-Object Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
$allglobalserver = Get-ADComputer -Server GB00WDSSAPP03P.global.icap.com -Filter * -Properties Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -or ($_.OperatingSystem -like 'NULL')} | Select-Object Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
$allukserver = Get-ADComputer -Server UK0WDSSAPP04P.uk.icap.com -Filter * -Properties Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -or ($_.OperatingSystem -like 'NULL')} | Select-Object Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
$allusserver = Get-ADComputer -Server USICAPDCS03.us.icap.com -Filter * -Properties Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -or ($_.OperatingSystem -like 'NULL')} | Select-Object Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet
$allapacserver | Export-CSV C:\temp\all_forest_Windows_servers_CN.csv -NTI -Encoding UTF8
$allcorpserver | Export-CSV C:\temp\all_forest_Windows_servers_CN.csv -Append -NTI -Encoding UTF8
$alleurserver | Export-CSV C:\temp\all_forest_Windows_servers_CN.csv -Append -NTI -Encoding UTF8
$allnaserver | Export-CSV C:\temp\all_forest_Windows_servers_CN.csv -Append -NTI -Encoding UTF8
$allglobalserver | Export-CSV C:\temp\all_forest_Windows_servers_CN.csv -Append -NTI -Encoding UTF8
$allukserver | Export-CSV C:\temp\all_forest_Windows_servers_CN.csv -Append -NTI -Encoding UTF8
$allusserver | Export-CSV C:\temp\all_forest_Windows_servers_CN.csv -Append -NTI -Encoding UTF8

Get-ADComputer -Filter * -Properties Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet | Where-Object {($_.OperatingSystem -like '*Server*') -or ($_.OperatingSystem -like 'NULL')} | Select-Object Name,CanonicalName,DNSHostName, LastLogonDate,OperatingSystem,DistinguishedName,PasswordLastSet | Export-CSV C:\temp\all_servers.csv -NTI -Encoding UTF8
