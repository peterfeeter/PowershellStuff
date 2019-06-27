# getting the IP's from the file

$IPADDRS = Get-Content "C:\temp\IP_Test.txt"

$result = @()
ForEach ($IPADDR in $IPADDRS)
{
  $result += [System.Net.DNS]::GetHostbyAddress($IPADDR) | Add-Member -Name IP -Value $IPADDR -MemberType NoteProperty -PassThru | Select-Object IP, HostName
}
$result  | Sort-Object -property IP | export-csv "C:\temp\ReverseLookup.csv" -NoTypeInformation