#Move csv users to DisabledItems in Corp
# Specify target OU.This is where users will be moved. 
$TargetOU =  "OU=Disabled Items,DC=corp,DC=ad,DC=tullib,DC=com" 
# Import the data from CSV file and assign it to variable  
$Imported_csv = Import-Csv -Path "C:\temp\DisabledUserTest.csv"  

#Store admin credential to move accounts
$CorpAdminCredential = Get-Credential -Username pmorgan-a@corp.ad.tullib.com -Message "TP Active Directory"
$GlobalAdminCredential = Get-Credential -Username pmorgan-a@global.icap.com -Message "ICAP Active Directory"

#ForEach loop
$Imported_csv | ForEach-Object { 
     # Retrieve DN of User. 
     $UserDN  = (Get-ADUser -Identity $_.SamAccountName).distinguishedName
     #Remove Deletion Protection from account
     get-aduser $UserDN -Server "GB00WDSSAPP01P.global.icap.com" | set-adobject -Credential $CorpAdminCredential -ProtectedFromAccidentalDeletion $false
     Write-Host " Moving Accounts... " 
     # Move user to target OU. 
     Move-ADObject -Credential $CorpAdminCredential -Identity $UserDN -TargetPath $TargetOU  
 } 
 #Status
 Write-Host " Completed move "  
 $total = ($Imported_csv).count 
 Write-Host "  $total accounts have been moved succesfully..."

 #Connect-AzureAD
 # 
 #$User = Get-AzureAdUser -SearchString peter.morgan@tpicap.com | Select -ExpandProperty AssignedLicenses
 #Get-AzureADUser -ObjectId 468ae566-ec04-4410-8f0b-b0836d9b0efc | Select -ExpandProperty AssignedLicenses | fl
 #Get-AzureADUser -ObjectId $User.ObjectId | Select -ExpandProperty AssignedLicenses | fl
 #$License = New-Object -TypeName Microsoft.Open.AzureAD.Model.AssignedLicense
 #$License.SkuId = "6fd2c87f-b296-42f0-b197-1e91e994b900"
 
