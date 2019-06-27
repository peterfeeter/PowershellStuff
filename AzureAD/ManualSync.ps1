
#Invoke a manual sync
$UserCredential = Get-Credential -Username pmorgan-a@corp.ad.tullib.com -Message "Azure Active Directory Connect"
$AADCComputer = "LDNPINF36501"
$AADCsession = New-PSSession -ComputerName $AADCComputer -Credential $UserCredential
Invoke-Command -Session $AADCsession -ScriptBlock {Import-Module -Name 'ADSync'}
#Invoke-Command -Session $AADCsession -ScriptBlock {Get-ADSyncScheduler}
Invoke-Command -Session $AADCsession -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
Remove-PSSession $AADCsession 

#Get Configuration and export to AADConnectDocumenter tool
$UserCredential = Get-Credential -Username pmorgan-a@corp.ad.tullib.com -Message "Azure Active Directory Connect"
$AADCComputer = "LDNPINF36501"
$AADCsession = New-PSSession -ComputerName $AADCComputer -Credential $UserCredential
Invoke-Command -Session $AADCsession -ScriptBlock {Import-Module -Name 'ADSync'}
#Invoke-Command -Session $AADCsession -ScriptBlock {Get-ADSyncScheduler}
Invoke-Command -Session $AADCsession -ScriptBlock {Get-ADSyncServerConfiguration -Path "D:\AzureADConnectSyncDocumenter\Temp"}
Remove-PSSession $AADCsession

#Set-ADSyncAutoUpgrade -AutoupGradeState Enabled

$UserCredential = Get-Credential -Username pmorgan-a@corp.ad.tullib.com -Message "Azure Active Directory Connect"
$AADCComputer = "LDNPINF36501"
$AADCsession = New-PSSession -ComputerName $AADCComputer -Credential $UserCredential
Invoke-Command -Session $AADCsession -ScriptBlock {Import-Module -Name 'ADSync'}
#Invoke-Command -Session $AADCsession -ScriptBlock {Get-ADSyncScheduler}
Invoke-Command -Session $AADCsession -ScriptBlock {Get-ADSyncExportDeletionThreshold}
Remove-PSSession $AADCsession 

