$Array = Import-Csv "C:\temp\mxdomains.csv"
foreach($mx in $Array) 
{ 
    Resolve-DnsName -Name $MX.Name -Type MX | Select-Object @{name='Domain'; expression={$MX.Name}},Name | Export-CSV C:\temp\mx_audit.csv -NTI -Append
}

