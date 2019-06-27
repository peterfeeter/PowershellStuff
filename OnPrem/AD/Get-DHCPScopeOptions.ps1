$domain = “corp”
$domainsearch = "*$domain*"
Add-Content -Value "SERVERNAME,SCOPEID,SCOPENAME,OPTIONID, OPTIONNAME, OPTIONTYPE, OPTIONVALUE" -Path ("C:\temp\" + $domain + "_DHCP_Scope_Options.csv")
$dhcpservers = (Get-ADObject -SearchBase 'cn=configuration,dc=ad,dc=tullib,dc=com' -Filter 'objectclass -eq "dhcpclass" -AND name -ne "dhcproot" -AND name -like $domainsearch').name
#$dhcpservers = "ldnpinfdcp03.corp.ad.tullib.com"
Foreach ($dhcpserver in $dhcpservers) {
     $Scopes = Get-DhcpServerv4Scope -ComputerName $dhcpserver | Select-Object ScopeId,Name
        foreach ($Scope in $Scopes) {
        $Options = Get-DhcpServerv4OptionValue -ComputerName $dhcpserver -ScopeId $Scope.ScopeId.IPAddressToString -All | Sort-Object -Descending -Property OptionId
            for ($i = ($Options.Count -1); $i -gt -1; $i--) {
            Add-Content -Value "$($dhcpserver),$($Scope.ScopeId.IPAddressToString),$($Scope.Name),$($Options[$i].OptionId),$($Options[$i].Name),$($Options[$i].Type),$($Options[$i].Value -join ',')" -Path "C:\temp\Windows_Scope_Options.csv"
            }
        } 
} 