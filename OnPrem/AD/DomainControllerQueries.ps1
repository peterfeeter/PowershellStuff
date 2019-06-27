#Get all DCs in forest, and then export to csv
(Get-ADForest).Domains | ForEach-Object{ Get-ADDomainController -Filter * -Server $_ } | Select-Object Name, Domain, Site, OperatingSystem, IsGlobalCatalog | Export-Csv "C:\temp\TP Domain check\TP_DCs.csv" -NTI
#$allDCs = (Get-ADForest).Domains | ForEach-Object{ Get-ADDomainController -Filter * -Server $_ } | Select-Object Name, Domain, Site, OperatingSystem, IsGlobalCatalog

#Get a DC relevant info
Get-ADDomainController -Properties  -Server LDNPINFDCG01 | Format-List select Name, Domain, Site, OperatingSystem, IsGlobalCatalog

#Get info on domain
(Get-ADForest).Domains | ForEach-Object{ Get-ADDomain -Identity $_ | Select-Object DomainMode,RIDMaster,PDCEmulator,InfrastructureMaster}
Get-ADDomain -Identity corp.ad.tullib.com | Select-Object DomainMode,RIDMaster,PDCEmulator,InfrastructureMaster | Format-List

#Get info on forest
Get-ADForest | Format-List

#query to get accounts that have DES enabled
Get-ADUser -Filter pmorgan -Properties * | Where-Object {$_.UseDESKeyOnly -eq "True"} | select-object name, SamAccountName, UserPrincipalName, CanonicalName, UseDESKeyOnly
Get-ADComputer msDC-SupportedEncryptionTypes

#Get DomainControllers and list useful info about them
Function Get-DCDetails {
    [CmdletBinding()]
    Param(
    )
    $Domains = (Get-ADForest).Domains
    $DCs = $Domains | % { Get-ADDomainController -Filter * -Server $_  }
    foreach($DC in $DCs) {
      $OutputObj = New-Object -TypeName PSObject -Property @{
              DCName = $User.Name;
              DCDomain = $null;
              IsGC = $null;
              SiteName = $Null;
              IsOnline = $null
            }
      if(Test-Connection -Computer $DC -Count 1 -quiet) {
        $OutputObj.IsOnline = $true
      } else {
        $OutputObj.IsOnline = $false
      }
        $OutputObj.DCName = $DC.HostName
      $OutputObj.DCDomain = $DC.Domain
      $OutputObj.IsGC = $DC.IsGlobalCatalog
      $OutputObj.SiteName = $DC.Site
      $OutputObj
    }
    }



