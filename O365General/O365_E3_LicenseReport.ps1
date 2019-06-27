# Original source: https://gallery.technet.microsoft.com/scriptcenter/Export-a-Licence-b200ca2a?tduid=(26fc5a009171934296bd78c7f4dd6590)(256380)(2459594)(TnL5HPStwNw-0Z3.3otQ5VeALpBrI1CXBg)()
# Adapted by: Peter Morgan
# Date modified: 01/02/2019

# Run powershell as user CORP\srvcinfps and then use this code to update the user and password
# Get-Credential | Export-CliXml -Path D:\Scripts\MessagingAlerts\Cred\o365_cred.xml

#Logging
#$ErrorActionPreference="SilentlyContinue"
#Stop-Transcript | out-null
#$ErrorActionPreference = "Continue"
#Start-Transcript -path D:\Scripts\MessagingAlerts\reportoutput.txt -append

$credential = Import-Clixml -Path "D:\Scripts\MessagingAlerts\Cred\o365_cred.xml"
$VerbosePreference = 'Continue'    # Makes verbose

# Import required modules
Import-Module AzureAD
Import-Module MSOnline

# Connect to Microsoft Online
Connect-MsolService -Credential $credential

# Get a list of interesting license types. Currently only gets E3 license, remove the AccountSkuId from the WHERE if you want all licenses. 
# Though not sure how that will play with the rest of the script...
$licensetype = Get-MsolAccountSku | Where {($_.ConsumedUnits -ge 1) -and ($_.AccountSkuId -eq "Tpicap365:ENTERPRISEPACK")}

Write-Verbose "License types are:" 
$lts = $licensetype| select -expandproperty accountskuid | Format-Table -Autosize | Out-String
Write-Verbose $lts

Write-Verbose "Getting all users (may take a while) ..."
$allusers = Get-MsolUser -all 
Write-Verbose ("There are " + $allusers.count + " users in total")

# Loop through all licence types found in the tenant
foreach ($license in $licensetype) 
{ 
 # Build and write the Header for the CSV file
    $LicenseTypeReport = "D:\Scripts\MessagingAlerts\O365LicenseReports\Office365_" + ($license.accountskuid -replace ":","_") + "_" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".csv"
    Write-Verbose ("New file: "+ $LicenseTypeReport)

 $headerstring = "DisplayName;UserPrincipalName;ImmutableID;JobTitle;Office;AccountSku"
 
 foreach ($row in $($license.ServiceStatus)) 
 {
  $headerstring = ($headerstring + ";" + $row.ServicePlan.servicename)
 }
 
 Out-File -FilePath $LicenseTypeReport -InputObject $headerstring -Encoding UTF8 -append
 
 write-Verbose ("Gathering users with the following subscription: " + $license.accountskuid)

 # Gather users for this particular AccountSku
 $users = $allusers | where {$_.isLicensed -eq "True" -and $_.licenses.accountskuid -contains $license.accountskuid}

 # Loop through all users and write them to the CSV file
 foreach ($user in $users) {
  
        $thislicense = $user.licenses | Where-Object {$_.accountskuid -eq $license.accountskuid}
        $datastring = (($user.displayname -replace ","," ") + ";" + $user.userprincipalname + ";" + $user.ImmutableID + ";" + $user.Title + ";" + $user.Office + ";" + $license.SkuPartNumber)
  
  foreach ($row in $($thislicense.servicestatus)) {   
   # Build data string
   $datastring = ($datastring + ";" + $($row.provisioningstatus))
  }  
  Out-File -FilePath $LicenseTypeReport -InputObject $datastring -Encoding UTF8 -append
  }

} 

write-Verbose ("Source report completed. Now we do things to it to make it useful, yeah?")

# This part is not from the MS gallery. You can tell cause I like to write unnecessarily verbose commentary in the hope this justifies my shoddy coding abiltiy.
# The file is semi-colon delimited to take into account commas in names? Probably could ignore this but I can't be bothered to test, I'd rather it be an actual CSV for how I intend to use it.
# This bit converts the report to a proper csv and then removes the original semi-colon one.
$FinalCSVpath = "D:\Scripts\MessagingAlerts\O365LicenseReports\finallicence_" + ($license.accountskuid -replace ":","_") + "_" + (Get-Date -Format "yyyyMMdd") + ".csv"
Import-Csv -Path $LicenseTypeReport -Delimiter ';' | Export-Csv -Path $FinalCSVpath -Delimiter ',' -NoType
Remove-Item -Path $LicenseTypeReport

# Compare todays report with yesterdays report.
# Get yesterdays file for comparison, and store the diffs
$YesterdayCSVpath = "D:\Scripts\MessagingAlerts\O365LicenseReports\finallicence_" + ($license.accountskuid -replace ":","_") + "_" + (Get-Date).AddDays(-1).ToString('yyyyMMdd') + ".csv"
$DiffCSVpath = "D:\Scripts\MessagingAlerts\O365LicenseReports\Diffs\license_Diff_" + (Get-Date -Format "yyyyMMdd") + ".csv"

$file1 = import-csv -Path $FinalCSVpath
$file2 = import-csv -Path $YesterdayCSVpath
Compare-Object $file1 $file2 -property ImmutableID -PassThru| Export-CSV $DiffCSVpath -NoTypeInformation
# Makes file easier to parse with human person eyes
$content = get-content $DiffCSVpath
$NCContent = $content -replace '==','=='
$RMContent = $NCcontent -replace '=>','E3 Removed'
$ADContent = $RMcontent -replace '<=','E3 Added'
Set-Content $DiffCSVpath $ADcontent
# Re-Order Columns
(Import-CSV -Path $DiffCSVpath) | Select-Object -Property SideIndicator,DisplayName,UserPrincipalName,ImmutableID,JobTitle,Office,AccountSku,SHAREPOINTENTERPRISE,EXCHANGE_S_ENTERPRISE,TEAMS1,INTUNE_O365,OFFICESUBSCRIPTION,BPOS_S_TODO_2,SHAREPOINTWAC,FORMS_PLAN_E3,STREAM_O365_E3,Deskless,FLOW_O365_P2,POWERAPPS_O365_P2,PROJECTWORKMANAGEMENT,SWAY,YAMMER_ENTERPRISE,RMS_S_ENTERPRISE,MCOSTANDARD | Export-CSV -Path $DiffCSVpath -NTI

write-Verbose ("Compare and diff completed.")

# Now convert CSV to html table, only bringing interesting columns
$htmlpath = "D:\Scripts\MessagingAlerts\O365LicenseReports\O365License_" + (Get-Date -Format "yyyy-MM-dd") + ".html"
$css = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; box-shadow: 10px 10px 5px #888; border: thin ridge grey; }
th { background: #0046c3; color: #fff; max-width: 400px; padding: 5px 10px; }
td { font-size: 11px; padding: 5px 20px; color: #000; }
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@
Import-CSV -Path $DiffCSVpath | Select-Object -Property SideIndicator,UserPrincipalName,JobTitle,Office,SHAREPOINTENTERPRISE,EXCHANGE_S_ENTERPRISE,TEAMS1,INTUNE_O365,OFFICESUBSCRIPTION | ConvertTo-Html -Head $css -Body "<h1>O365 License Report</h1>`n<h5>Generated on $(Get-Date -Format "yyyyMMdd")</h5>" | Out-File $htmlpath

write-Verbose ("HTML conversion completed.")


Connect-AzureAD -Credential $credential
$E3 = Get-AzureADSubscribedSku | Where-Object {$_.SkuPartNumber -eq "ENTERPRISEPACK"} | Select -Property Sku*,ConsumedUnits -ExpandProperty PrepaidUnits
$E3TotalFree = ($E3.Enabled - $E3.ConsumedUnits)

# Send html in email
$htmldata = Get-Content $htmlpath -Raw
$body = @"
    <!DOCTYPE HTML>
    <html>
        <Head>
            <style>
                body {}
				table {width: 100%; }
                table, th, td  {
                    font-family: Segoe UI;
                    border: 2px solid white;
                    border-collapse: collapse;
                    background-color: #daeded;
                }
            </style>
        </head>
        <body>
          There are $E3TotalFree remaining E3 licenses available in the TPICAP365 tenant. See assignment changes in the last 24 hours below.
          <br>
          $htmldata
          <br>
          Alert generated from LDNPINFADM05: count of available E3 licenses, and assignment changes in a 24 hour period.
        </body>
    </html>
"@
$Splat = @{
        SmtpServer  = 'emeasmtp.eur.ad.tullib.com'
        Body        = $body
        BodyAsHtml  = $true
        #To          = 'peter.morgan@tpicap.com'
        To          = 'GlobalMessagingAdministration@tullettprebon.com'
        #CC          = 'GlobalMessagingAdministration@tullettprebon.com'
        From        = 'O365LicenseReport@tpicap.com'
        Subject     = 'O365 License Report Generated on ' + $(Get-Date -Format "yyyy-MM-dd")
           }
Send-MailMessage @Splat
write-Verbose ("Email sent.")
    
# Tidy up some old files now please so there aren't 000s of files building up. Keeping two weeks worth of source report CSV so we can re-run against old data if needed.
$htmlyesterdaypath = "D:\Scripts\MessagingAlerts\O365LicenseReports\O365License_" + (Get-Date).AddDays(-2).ToString('yyyyMMdd') + ".html"
$DiffyesterdayCSVpath = "D:\Scripts\MessagingAlerts\O365LicenseReports\Diffs\license_Diff_" + (Get-Date).AddDays(-2).ToString('yyyyMMdd') + ".csv"
$oldFinalCSVpath = "D:\Scripts\MessagingAlerts\O365LicenseReports\finallicence_" + ($license.accountskuid -replace ":","_") + "_" + (Get-Date).AddDays(-7).ToString('yyyyMMdd') + ".csv"
Remove-Item -Path $htmlyesterdaypath
Remove-Item -Path $DiffyesterdayCSVpath
Remove-Item -Path $oldFinalCSVpath

#write-Verbose ("Tidied old files.")
write-Verbose ("Script Completed.")

#Stop-Transcript