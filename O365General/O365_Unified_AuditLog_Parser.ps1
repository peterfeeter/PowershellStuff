<#PSScriptInfo 
 
.VERSION 1.1 
 
.GUID 2082a2b3-155c-42e5-b3f6-c67434a0a3e1 
 
.AUTHOR mikko@lavento.com 
 
.COMPANYNAME 
 
.COPYRIGHT 
 
.TAGS O365 UnifiedAuditlog Auditlog parser 
 
.LICENSEURI 
 
.PROJECTURI 
 
.ICONURI 
 
.EXTERNALMODULEDEPENDENCIES 
 
.REQUIREDSCRIPTS 
 
.EXTERNALSCRIPTDEPENDENCIES 
 
.RELEASENOTES 
 
 
#> 













<# 
 
.DESCRIPTION 
  
O365 auditlog (Unified log) parser. 
 
Applies to logs downloaded from https://protection.office.com - Search & investigation - Audit log search - Download - .csv 
 
Downloaded log has 4 colums: 
CreationDate | UserIds | Operations | Auditdata 
Problem: the most important one (Auditdata) is string mess where data is delimited with ; , and [] and you can't really import it to excel to filter reasonably for examing. 
Also problem: different services log more or less data so no fixed amount of columns 
 
This parser will modify the Auditdata column, creates a table and exports the parsered csv file (to be imported to excel). 
More comments inside the script. 
 
 
#> 

Param()


# 29.5.2018 M.Lavento
# O365 auditlog (Unified log) parser
# Applies to logs downloaded from https://protection.office.com - Search & investigation - Audit log search - Download .csv
#

# Downloaded log has 4 colums 
# CreationDate | UserIds | Operations | Auditdata
# Problem: the most important one (Auditdata) is "string mess" where data is delimited with ; , and [] and you can't really import it to excel to filter reasonably.
# Also problem: different services log more or less data so no fixed amount of columns

# Solution: delimiter to be used while importing to Excel seems to be "," BUT NOT INSIDE brackets [{ }] so we change all "," --> �� as delimiter inside brackets []
# Delimiter char changes atleast for me to �� --> ??, but it doesn't really matter
# Then we can split and construct a table in a format where it is csv exportable


# But first Columns for the result table# 
# Bad thing is that cloumns has to be known beforehand.
# Used Microsoft's own info what they might be and I added atleast five extra ones what came up while testing
# https://support.office.com/en-us/article/detailed-properties-in-the-office-365-audit-log-ce004100-9e7f-443e-942b-9b04098fcfc3

# But because it's Microsoft and there might be more in the future or misinterpretations in the code we have to create the headers.

# I created column name Miscellaneous as the last column

$columnheaders = `
"CreationDate",`
"UserIds",`
"Operations",`
"Actor",`
"ActorContextId",`
"ActorIpAddress",`
"AddOnName",`
"AddOnType",`
"ApplicationDisplayName",`
"ApplicationId",`
"AzureActiveDirectoryEventType",`
"ChannelGuid",`
"ChannelName",`
"Client",`
"ClientInfoString",`
"ClientIP",`
"ClientIPAddress",`
"CorrelationId",`
"CreationTime",`
"CustomUniqueId",`
"DestinationFileExtension",`
"DestinationFileName",`
"DestinationRelativeUrl",`
"EventData",`
"EventSource",`
"ExternalAccess",`
"ExtendedProperties",`
"ID",`
"InternalLogonType",`
"InterSystemsId",`
"IntraSystemId",`
"ItemType",`
"ListId",`
"ListItemUniqueId",`
"LoginStatus",`
"LogonError",`
"LogonType",`
"MailboxGuid",`
"MailboxOwnerUPN",`
"Members",`
"ModifiedProperties (Name, NewValue, OldValue)",`
"ObjectID",`
"Operation",`
"OrganizationID",`
"OrganizationName",`
"OriginatingServer",`
"Path",`
"Parameters",`
"RecordType",`
"ResultStatus",`
"SecurityComplianceCenterEventType",`
"SharingType",`
"Site",`
"SiteUrl",`
"SourceFileExtension",`
"SourceFileName",`
"SourceRelativeUrl",`
"Subject",`
"TabType",`
"Target",`
"TargetContextId",`
"TeamGuid",`
"TeamName",`
"UserAgent",`
"UserDomain",`
"UserID",`
"UserKey",`
"UserSharedWith",`
"UserType",`
"Version",`
"WebId",`
"Workload",`
"Miscellaneous"





############# Main script

#Open dialog by Dan Stolts
$openFileDialog = New-Object windows.forms.openfiledialog   
$openFileDialog.initialDirectory = [System.IO.Directory]::GetCurrentDirectory()   
$openFileDialog.title = "Select Log File to be parsered"   
$openFileDialog.filter = "CSV Files|*.csv|All Files|*.*" 
$openFileDialog.ShowHelp = $True   
Write-Host "Select Downloaded Settings File... (see FileOpen Dialog)" -ForegroundColor Green  
$result = $openFileDialog.ShowDialog()   # Display the Dialog / Wait for user response 
# in ISE you may have to alt-tab or minimize ISE to see dialog box 
$result 
if($result -eq "OK")    {    
    Write-Host "Selected Downloaded Settings File:"  -ForegroundColor Green  
    $OpenFileDialog.filename   
} 
else { Write-Host "File Selection Cancelled!" -ForegroundColor Yellow; exit} 

$logsource = $openFileDialog.FileName
$logdirectory = Split-Path -Parent $logsource
$exported_log = $logsource -replace ".csv","_parsered.csv"

#Progressbar Start time
$PBStartTime = Get-Date

$log = Import-Csv -Path $logsource

#Choose �� for chars replacing the , inside certain Auditdata's values, namely between: [{ }] 
#check if there is already �� in original log to be sure

$ErotinCount = [regex]::matches($log,����).count
if ($ErotinCount -eq 0)
{
$ErotinChar = "��"
}
else
{
$ErotinChar = "�M�"   
}

#total amount of rows in the log
$rivienmaara = $log.count
$rivilaskuri = 0

#create table to be populated, if exists then remove
$tabName = "O365LogTable"

if (Get-Variable -Name table -ErrorAction SilentlyContinue)
{
Remove-Variable table
}
$table = New-Object system.Data.DataTable �$tabName�


# Build table columns
$columnloop = 0
$cols = @()
$colheaders = @()
do
{
$cols += $columnheaders[$columnloop]
$colheaders += New-Object system.Data.DataColumn $cols[$columnloop],([string])

#Add the Columns
$table.columns.add($colheaders[$columnloop])

$columnloop++
}
until ($columnloop -gt ($columnheaders.count)-1)



# Begin to parser line by line

do
{
$string = $log[$rivilaskuri]

$parseredstring = $string

#trimming brackets 
$parseredstring.Auditdata = $parseredstring.Auditdata.Trim("{","}")

$parseredstringaudit = $parseredstring.AuditData
    
    #NonGreedy, fecth only [{ }] and all of them to regex-groups
    $AllMatches = $parseredstringaudit | Select-String -Pattern "\[{.*?\}]" -AllMatches | foreach {$_.Matches}
   
    $matchcount = $AllMatches.Count
   
    if($AllMatches.Success)            
    {            
            
        #if only one hit, then don't iterate by items

        if($matchcount -eq 1){

            $old = $AllMatches.Value
            $New = $old -replace ",",$ErotinChar
   
            $parseredstringaudit = $parseredstringaudit.Replace($old,$new)
            $parsered = $parseredstringaudit

        }
        else
        {
            $matchloop = 0

           
            #loop line with regex-hits and replace comma (,) --> �� ONLY inside [{ }] 
            do
            {
            
            $old = $AllMatches[$matchloop].Value
            $New = $old -replace ",",$ErotinChar
   
            $parseredstringaudit = $parseredstringaudit.Replace($old,$new)
            $parsered = $parseredstringaudit

            $matchloop++
            }
            until ($matchloop -gt $matchcount-1)
         }
     }

 
    ######## Done replacing between [{ }]

    #after that we still have to look if there is ", " (<= ,<empty>) in the line 
    
    #NonGreedy, fecth only ", " and all of them to regex-groups
    $AllMatches = $parseredstringaudit | Select-String -Pattern "\, " -AllMatches | foreach {$_.Matches}
    $matchcount = $AllMatches.Count

    if($AllMatches.Success)            
    {                    
        #if only one hit, then don't iterate by items

        if($matchcount -eq 1){

            $old = $AllMatches.Value
            $New = $old -replace ",",$ErotinChar
   
            $parseredstringaudit = $parseredstringaudit.Replace($old,$new)
            $parsered = $parseredstringaudit

        }
        else
        {
            $matchloop = 0

           
            #loop line with regex-hits and replace comma (,) --> �� ONLY inside [{ }] 
            do
            {
            
            $old = $AllMatches[$matchloop].Value
            $New = $old -replace ",",$ErotinChar
   
            $parseredstringaudit = $parseredstringaudit.Replace($old,$new)
            $parsered = $parseredstringaudit

            $matchloop++
            }
            until ($matchloop -gt $matchcount-1)
         }
     }

 
        ######## Done ", " -replacements
        
        # and now we are able to split

        $parseredsplitted = $parsered.Split(",")
        $parseredsplitcount = $parseredsplitted.Count

        $splitloop = 0

        #Create a row to table
        $row = $table.NewRow()
        
        #loop and get headers and values
        do
        {
    
        #header (left-part) and value (right part)
        $pos = $parseredsplitted[$splitloop].IndexOf(":")
        
        $leftPart = $parseredsplitted[$splitloop].Substring(0, $pos)
        $rightpart = $parseredsplitted[$splitloop].Substring($pos+1)

        #trim "

        $leftPart = $leftPart.Trim('"','"')
        $rightpart = $rightpart.Trim('"','"')


        ##### populate the values based on headers
        ##### best part of this that you can populate table by pointing to header names.
        ##### we don't have to worry about missing column values in the log row

        #find matching header "number"
        $colnumber = $table.Columns.IndexOf($leftPart)
        #If there is no match then use Miscellaneous-column
        if ($colnumber -eq "-1")
        {
        $colnumber = $table.Columns.IndexOf("Miscellaneous")
        Write-Host "No column, using misc, linenumber: $rivilaskuri"
        }

        #Enter data in the row
        $row.($cols[$colnumber]) = $rightpart

        $splitloop++
        }
        until ($splitloop -gt $parseredsplitcount-1)
  

        #Let's add three first columns to row from the original log
        $row.($cols[0]) = $log[$rivilaskuri].CreationDate
        $row.($cols[1]) = $log[$rivilaskuri].UserIds
        $row.($cols[2]) = $log[$rivilaskuri].Operations

        #Add the populated row to the table
        $table.Rows.Add($row)

        #skip to next line in log
        $rivilaskuri++   
        
        #Show some progresinfo to user
         
        ## -- Calculate The Percentage Completed
        [Int]$Percentage = ($rivilaskuri/$rivienmaara)*100
        #$PB.Value = $Percentage

        #calculate seconds
        $SecondsElapsed = ((Get-Date) - $PBStartTime).TotalSeconds
        $SecondsRemaining = ($SecondsElapsed / ($rivilaskuri/$rivienmaara)) - $SecondsElapsed

        #transform to more readable format
        $kulsek =  [timespan]::fromseconds($SecondsElapsed)
        $sekunnitkulunut = $kulsek.ToString("hh\:mm\:ss")

        $jalsek =  [timespan]::fromseconds($SecondsRemaining)
        $sekunnitjaljella = $jalsek.ToString("hh\:mm\:ss")

        Write-Progress -Activity "Prosessing" -Status "Processing: $rivilaskuri / $rivienmaara Elapsed Time: $sekunnitkulunut, Estimated time left: $sekunnitjaljella" -PercentComplete $Percentage
      
}
until ($rivilaskuri -gt $rivienmaara-1)

#close the bar
Write-Progress -Activity "Prosessing" -Status "Ready" -Completed

#Display the table
#$table | Format-Table


$table | Export-Csv -Path $exported_log -NoTypeInformation
Write-Host "`nOriginal log: $logsource" -ForegroundColor Yellow 
Write-Host "Parsered log: $exported_log`n" -ForegroundColor Yellow 


# Ask user if wants to open web-page where O365 detailed log is

Write-host "Would you like to open in browser detailed O365-log properties webpage (Microsoft's)?" -ForegroundColor Yellow 
    $Readhost = Read-Host " ( y / n ) " 
    Switch ($ReadHost) 
     { 
       Y {Write-host "Yes,opening"; Start-Process "https://support.office.com/en-us/article/detailed-properties-in-the-office-365-audit-log-ce004100-9e7f-443e-942b-9b04098fcfc3"} 
       N {Write-Host "No"; $PublishSettings=$false} 
       Default {Write-Host "Default, opening"; Start-Process "https://support.office.com/en-us/article/detailed-properties-in-the-office-365-audit-log-ce004100-9e7f-443e-942b-9b04098fcfc3"} 
     } 


# Ask user if wants to open Folder of Parsered-csv 

Write-host "Would you like to open Folder of End-Product ie. Parsered-csv?" -ForegroundColor Yellow 
    $Readhost = Read-Host " ( y / n ) " 
    Switch ($ReadHost) 
     { 
       Y {Write-host "Yes,opening"; Invoke-Item $logdirectory} 
       N {Write-Host "No"; $PublishSettings=$false} 
       Default {Write-Host "Default, opening"; Invoke-Item $logdirectory} 
     }  
