#########################################################################################
# Active Directory / Office 365 User Termination Script
# 
# Intended for use in O365 environments synchronizing local AD with Azure AD
#
# Input file names.csv required to be located in same directory as script
# Input file names.csv contains single column with header "USERID" listing SAMAccount
# name of user(s) to be terminated
#
# Author:                 Jim Rinkenberger
# Version:                1.0
# Last Modified Date:     8/1/2018
#########################################################################################

### Check for Input file
$InputFile = $PSScriptRoot + '\names.csv'
$TestPath = Test-Path -Path $InputFile
If ($TestPath -like "false") {
  Write-Host "Input file 'names.csv' not found"  -ForegroundColor Red
  Exit
}

### Import PS Modules
Import-Module ActiveDirectory
Import-Module MSOnline
### Connect to O365
$ADCredentials = Get-Credential -Message "Enter Active Directory Admin Credentials"
Connect-MsolService
Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter Microsoft.Exchange.Management.ExoPowershellModule.dll -Recurse ).FullName|?{$_ -notmatch "_none_"}|select -First 1)
$EXOSession = New-ExoPSSession
Import-PSSession $EXOSession

$SuccessLog = @()
$FailureLog = @()
### Get user address
$Csv = Import-Csv $InputFile
foreach ($Line in $Csv) {
   $User = $Line.USERID
   Write-Host "Processing " $User
   # Check that User ID Exists
   $Searcher = [ADSISearcher]"(sAMAccountName=$User)"
   $Results = $Searcher.FindOne()
   If ($Results -ne $Null) {

   ### Disable User and change properties
   Disable-ADAccount $User -Credential $ADCredentials
   Sleep 3
   # Check if user object is actually disabled
   $IsEnabled = Get-ADUser $User | Select-Object -ExpandProperty enabled | ft -HideTableHeaders | Out-String
   $IsEnabled = $IsEnabled.trim()
	   if ($IsEnabled -eq "False") {
          $SuccessLog += $User
          # Get User and Manager Display Names and email address
          $UserAddress = Get-ADUser $User -Properties mail | Select-Object -ExpandProperty mail
          $UserDisplayName = Get-ADUser $User -Properties Name | Select-Object -ExpandProperty Name
          $ManagerName = Get-ADUser $User -Properties Manager | Select-Object @{n="ManagerName";e={(Get-ADUser -Identity $_.Manager -Properties displayName).DisplayName}} | ft -HideTableHeaders | Out-String
          # Check for blank manager name and adjust autoreply if necessary
          If($ManagerName) {
                    $Autoreply = "$UserDisplayName is no longer with the organization. Please contact $ManagerName at 1.800.555.1234 if you require assistance."
          } else {
                    $Autoreply = "$UserDisplayName is no longer with the organization. Please contact the Help Desk at 1.800.555.1234 if you require assistance."
          }
          Set-MailboxAutoReplyConfiguration -Identity $UserAddress -AutoReplyState Enabled -ExternalMessage $Autoreply -InternalMessage $Autoreply
          # Change user properties
          if ($UserAddress) { 
             Write-Host "Processing " $UserAddress
             Get-ADGroup -Filter {name -like "DL *"} | Remove-ADGroupMember -Member $User -Confirm:$False -Credential $ADCredentials
             Set-ADUser $User -Replace @{mailNickName="$($User)";msExchHideFromAddressLists="TRUE"} -Credential $ADCredentials
             Set-ADUser $User -Clear Manager,company,department,departmentNumber,division -Credential $ADCredentials
             # Convert mailbox to shared
             Set-Mailbox -Identity $UserAddress -Type "Shared" -IssueWarningQuota 45GB

             # Reset Random O365 Password
             set-msoluserpassword -UserPrincipalName $UserAddress -ForceChangePassword $False

             # Disable Client Access Settings
             Set-CASMailbox -Identity $UserAddress -ActiveSyncEnabled $False
             Set-CASMailbox -Identity $UserAddress -OWAforDevicesEnabled $False
             Set-CASMailbox -Identity $UserAddress -PopEnabled $False
             Set-CASMailbox -Identity $UserAddress -ImapEnabled $False

             # Remove all ActiveSync Devices
             $DevicesToRemove = Get-MobileDevice -Mailbox $UserAddress
             foreach ($device in $DevicesToRemove) {
                $mobile = $device.identity
                Remove-MobileDevice -identity $mobile -confirm:$false
             }

             # Remove from all O365 Distribution Groups
             Get-DistributionGroup -ResultSize Unlimited -Filter "Members -like ""$((get-Mailbox $UserAddress).DistinguishedName)""" | Remove-DistributionGroupMember -Member $UserAddress -BypassSecurityGroupManagerCheck -Confirm:$False

             # Remove from all O365 Unified Groups
             Get-UnifiedGroup -ResultSize Unlimited -Filter "Members -like ""$((get-Mailbox $UserAddress).DistinguishedName)""" | Remove-UnifiedGroupLinks -Links $UserAddress –LinkType Members -Confirm:$False

             # Remove all O365 licenses
             Write-Host Removing license for $UserAddress
             $MSOLSKU = (Get-MSOLUser -UserPrincipalName $UserAddress).Licenses.AccountSkuId
             foreach ($SKU in $MSOLSKU) {
                 Set-MsolUserLicense -UserPrincipalName $UserAddress -RemoveLicenses $SKU
             }

             # Remove O365 Picture
             Write-Host Removing user picture for $UserAddress
             Remove-UserPhoto -ClearMailboxPhotoRecord -Identity $UserAddress -Confirm:$false

             # Expire AD User object and move to Disabled_Users_Hold OU
             # Expiration date is used by another script later to move user object to OU outside of AzureAD COnnect sync scope
             $Today = Get-Date -Format d
             Set-ADAccountExpiration $User -DateTime $Today -Credential $ADCredentials
             Get-aduser $User | Move-ADObject -targetpath 'OU=Disabled_Users_Hold,OU=Disabled,DC=mycompany,DC=com' -Credential $ADCredentials
          }

      }
       if ($IsEnabled -eq "True") {$FailureLog += $User}
   }
   Else {$FailureLog += $User}
}
Remove-PSSession $EXOSession

###############################################################
# Create and send email report
If ($SuccessLog -ne $Null) { 
   $SMTPTo = "terminations@mycompany.com"
   $SMTPFrom = "scripts@mycompany.com"
   $SMTPServer = "SMTP.mycompany.com"
   $SMTPSubject = "User Termination Report"

   $SMTPDate = Get-Date -DisplayHint Date

   $SMTPEmailBody = "<h2>User Termination Report For $SMTPDate </h2>"
   $SMTPEmailBody += "<p>The following users have been disabled in Active Directory and Office 365.<br>"
   $SMTPEmailBody +="<p> </p>"
   Foreach ($LogLine in $SuccessLog) {
      $UserName = Get-ADUser $LogLine -Properties Name | Select-Object -ExpandProperty Name
      $UserAddress = Get-ADUser $LogLine -Properties mail | Select-Object -ExpandProperty mail
      $SMTPEmailBody +="<p>$UserName - $LogLine - $UserAddress</p>"
   }
   Send-MailMessage -From $SMTPFrom -To $SMTPTo -Subject $SMTPSubject -Body $SMTPEmailBody -SmtpServer $SMTPServer -BodyAsHtml
}
# Script end
Write-Host "SCROLL TO THE TOP OF THE SCREEN TO CHECK FOR WARNINGS OR ERRORS" -ForegroundColor Green
Write-Host "The following user terminations were successful:" -ForegroundColor Green
Write-Host $SuccessLog
Write-Host "The following user terminations were NOT successful:" -ForegroundColor Red
Write-Host $FailureLog
Read-Host "Hit Enter to Exit"

