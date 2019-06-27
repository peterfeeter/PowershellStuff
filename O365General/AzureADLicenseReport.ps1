$Result=@() 
Get-AzureADUser -All $True | ForEach-Object {
$IsLicensed = ($_.AssignedLicenses.Count -ne 0)
$Result += New-Object PSObject -property @{ 
Name = $_.DisplayName
UserPrincipalName = $_.UserPrincipalName
IsLicensed = $IsLicensed  }
}
$Result | Export-CSV "C:\\O365UsersLicenseStatus.csv" -NoTypeInformation -Encoding UTF8


(Get-AzureADUser -SearchString levine).AssignedPlans