$DomainServer = "bricapad1.br.icap.com"
# adtullibserverroot = "ldnpinfdcr03.ad.tullib.com"
# apacserver = "SNGPINFDCA03.apac.ad.tullib.com"
# corpserver = "LDNPINFDCG03.corp.ad.tullib.com"
# eurserver = "LDNPINFDCE01.eur.ad.tullib.com"
# naserver = "NJCPINFDCN02.na.ad.tullib.com"
# icapserverroot = "UK0WDSSAPP01P.icap.com"
# globalserver = "GB00WDSSAPP03P.global.icap.com"
# ukserver = "UK0WDSSAPP04P.uk.icap.com"
# usserver = "USICAPDCS03.us.icap.com"
# hkserver = "HKICAPAD01.hk.icap.com"
# sgserver = "SGADSRV02.sg.icap.com"
# jpnserver = "JPICAPAD01.jpn.icap.com"
# auserver = "AUICAPAD06.au.icap.com"
# brserver = "bricapad1.br.icap.com"

# Blank password acounts
Get-ADUser -Server $DomainServer -Filter {UserAccountControl -band 0x220} | Out-GridView
Get-ADUser -Server $DomainServer -Filter {UserAccountControl -band 0x10220} | Out-GridView

# Domain admin membership - run per domain as domain admin
Get-ADGroupMember -Server $DomainServer "Domain Admins" -Recursive | select Name,SamAccountName | Export-CSV C:\Temp\br_domainadmins.csv -NTI

# Run per domain as domain admin - Get SMB auditing for W2012 R2 DCs
$2012DCArray = Get-ADDomainController -Filter * | Where-Object {$_.OperatingSystem -like "Windows Server 2012*"} | Select-Object Name | sort Name -Descending
$Results = @()
foreach($2012DCs in $2012DCArray) 
{ 
    $auditsmb = Invoke-Command -ComputerName $2012DCs.Name -ScriptBlock {Get-SmbServerConfiguration | Select AuditSmb1Access, EnableSMB1Protocol, EnableSMB2Protocol}
    $Properties = @{
        Name = $2012DCs.Name
        SMBAudit = $auditsmb.AuditSmb1Access
        SMB2Enable = $auditsmb.EnableSMB2Protocol
        SMB1Enable = $auditsmb.EnableSMB1Protocol
    } 
    $Results += New-Object psobject -Property $properties | Export-Csv -notypeinformation -Path "C:\temp\rootad_smbaudit.csv" -Append
}

# Run per domain as domain admin - Set SMB auditing for W2012 R2 DCs
$2012DCArray = Get-ADDomainController -Filter * | Where-Object {($_.OperatingSystem -like "Windows Server 2012*")} | Select-Object Name | sort Name -Descending
foreach($2012DCs in $2012DCArray) 
{ 
    Invoke-Command -ComputerName $2012DCs.Name -ScriptBlock {Set-SmbServerConfiguration -AuditSmb1Access $true -Force}
}

# Run per domain, get SMB audit log contents
$2012DCArray = Get-ADDomainController -Filter * | Where-Object {($_.OperatingSystem -like "Windows Server 2012*")} | Select-Object Name | sort Name -Descending
$logdate = (Get-Date).AddDays(-3)
foreach($2012DCs in $2012DCArray)
 {
    Get-WinEvent -LogName Microsoft-Windows-SMBServer/Audit -ComputerName $2012DCs.Name | Where-Object {($_.TimeCreated -ge $logdate)} | Select-Object @{name='ComputerName'; expression={$2012DCs.Name}},TimeCreated, Message | Export-CSV C:\temp\gresa.csv -NTI -Append
}

# Get DNS Zones to protect from accidental deletion, per domain
Get-ADObject -Filter 'ObjectClass -like "dnszone"' -SearchScope Subtree -SearchBase "DC=DomainDnsZones,DC=eur,DC=ad,DC=tullib,DC=com" -properties ProtectedFromAccidentalDeletion | 
where {$_.ProtectedFromAccidentalDeletion -eq $False} | 
Select-Object name,protectedfromaccidentaldeletion | 
out-gridview

# Set DNS Zone to protect from accidental delete
Get-ADObject -Filter 'ObjectClass -like "dnszone"' -SearchScope Subtree -SearchBase "DC=DomainDnsZones,DC=eur,DC=ad,DC=tullib,DC=com" -properties ProtectedFromAccidentalDeletion | 
where {$_.ProtectedFromAccidentalDeletion -eq $False} | 
Set-ADObject –ProtectedFromAccidentalDeletion $true

# Get legacy DNS zone
Get-ADObject -Filter 'ObjectClass -like "dnszone"' -SearchScope Subtree -SearchBase "CN=MicrosoftDNS,CN=System,DC=eur,DC=ad,DC=tullib,DC=com" -properties ProtectedFromAccidentalDeletion | 
where {$_.ProtectedFromAccidentalDeletion -eq $False} | 
Select name,protectedfromaccidentaldeletion | 
out-gridview