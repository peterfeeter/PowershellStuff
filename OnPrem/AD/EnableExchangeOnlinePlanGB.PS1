$AccountSkuId = "Tpicap365:ENTERPRISEPACK"

$UsageLocation = “GB”

$LicenseOptions = New-MsolLicenseOptions -AccountSkuId $AccountSkuId -DisabledPlans @("FORMS_PLAN_E3","STREAM_O365_E3","Deskless","FLOW_O365_P2","POWERAPPS_O365_P2","TEAMS1","SWAY","YAMMER_ENTERPRISE","RMS_S_ENTERPRISE","MCOSTANDARD","SHAREPOINTWAC")

$Users = Get-Content D:\scripts\users.txt
foreach ($user in $users)
{
"$(get-date) - Modified License for $user" | add-content "D:\temp\LicensesModified.txt"

#New-MsolUserLicense -UserPrincipalName $user
#Set-MsolUserLicense -UserPrincipalName $user -AddLicenses $AccountSkuId -ea SilentlyContinue
sleep -Seconds 5
Set-MsolUserLicense -UserPrincipalName $user -LicenseOptions $licenseoptions
Set-MsolUser -UserPrincipalName $user -UsageLocation $UsageLocation

}