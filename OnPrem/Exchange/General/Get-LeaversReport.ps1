if ( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null )
{
Add-PSSnapIn Microsoft.Exchange.Management.PowerShell.E2010
}

#Set AD to view entire forest
$ADSettings = Get-ADServerSettings
If ($ADSettings.ViewEntireForest -eq $false) {Set-ADServerSettings -ViewEntireForest $true}

#Import Active Directory module
Import-module ActiveDirectory -ErrorAction SilentlyContinue


$LeaversReport = @()
$date = (get-date -f dd-MM-yy)

    #All User
    #$users = get-recipient -resultsize unlimited | where {$_.RecipientTypeDetails -eq "Usermailbox"}
    
    #Single user test
    #$users = get-recipient "Regina Cai"
    
    #Users from a file
    $users = import-csv d:\temp\userspj.csv
    
    foreach ($user in $users) {
    
    $1= get-mailbox $User.SamAccountName
    $2= $1 | get-mailboxstatistics
    $3= get-aduser -Properties * -filter {UserPrincipalName -eq $1.UserPrincipalName} -Server GB01WDSSAPP04P.icap.com:3268
        
    $ReturnedData = New-Object PSObject
	add-member -inputobject $ReturnedData  -membertype noteproperty -name "Displayname" -value $1.displayname
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "EmailAddress" -value $1.PrimarySMTPAddress
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "Recipient Type" -value $1.RecipientTypeDetails
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "Size" -value $2.TotalItemSize
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "LitigationHoldEnabled" -value $1.LitigationHoldEnabled
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "LitigationHoldDate" -value $1.LitigationHoldDate
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "Mbx Hidden" -value $1.HiddenFromAddressListsEnabled
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "Last Mbx Logon" -value $2.LastLoggedOnUserAccount
	add-member -inputobject $ReturnedData  -membertype noteproperty -name "Last Mbx Logon Time" -value $2.LastLogonTime
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "AD Enabled" -value $3.Enabled
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "Last AD Login" -value $3.LastLogondate
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "UPN" -value $1.UserPrincipalName
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "Alias" -value $1.Alias
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "Database" -value $1.Database
    add-member -inputobject $ReturnedData  -membertype noteproperty -name "Organizational Unit" -value $1.OrganizationalUnit
        
    $LeaversReport += $returneddata
    }

$LeaversReport | epcsv c:\temp\LeaversReportICAP-$date.csv -NoTypeInformation

