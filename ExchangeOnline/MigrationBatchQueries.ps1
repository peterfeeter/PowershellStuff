#Generate migration status XML for analysis with MRS_Explorer.ps1
Get-MoveRequest |Get-MoveRequestStatistics -IncludeReport | Export-CliXml "E:\Stuff\PowershellStuff\Exchange Online\MigReport.xml"

#Query existing batch stats
Get-MigrationBatch RQ0091969 | Format-List #To see all properties of a moverequest
Get-MigrationBatch "Hong Kong Users – 001" | Select-Object Identity,State, Status, LastSyncedDateTime #To see useful properties of a moverequest

#Query all mailbox moves to Exchange Online
Get-MoveRequest | Format-List #To see all properties of a moverequest to console
Get-MoveRequest  | Select-Object Identity, DisplayName, Alias, Status, Suspend, SuspendWhenReadyToComplete, RemoteHostName, BatchName, TargetDatabase, Flags | Export-Csv "C:\Temp\GetMoveEXO.csv"  #To see useful properties of a moverequest to csv

#Query all batches for a certain status such as Synced, Completed, Syncedwitherrors
Get-MigrationBatch -Status "Synced" | Format-List
Get-MigrationBatch -Status "Synced" | Select-Object Identity,State, Status, LastSyncedDateTime | Sort-Object -Descending LastSyncedDateTime

#Query all mailboxes within batches that are in sycned, failed state and list mailboxes ready for completion and output to csv.
Get-MigrationUser -Status Failed | Select-Object Identity,RecipientType,SkippedItemCount,SyncedItemCount,Status,BatchId,LastSuccessfulSyncTime, errorsummary | Export-Csv C:\temp\MigrationReports\Get-MigrationUserFailed20181026.csv -NTI

#Query for an existing specific mailbox or identity within all migration batches and return the batch it is in
Get-MigrationUser -Identity "Sami.Sajjad@tpicap.com" | Select-Object Identity,RecipientType,SkippedItemCount,SyncedItemCount,Status,BatchId,LastSuccessfulSyncTime, errorsummary
Get-MoveRequest  "Matthew.Forsyth@tpicap.com" | Get-MoveRequestStatistics | Format-Table displayname, percentcomplete, statusdetail

#Create multiple migration batches from csv for icap mailboxes, create a csv with the batchname as filename
Get-ChildItem E:\BatchMigrationCSVs\*.csv  | Foreach-Object{ 
    New-MigrationBatch -Name ($_.Name -replace ".csv","") -TargetDeliveryDomain "Tpicap365.mail.onmicrosoft.com" -AutoStart -AllowUnknownColumnsInCsv $true -NotificationEmails "peter.morgan@tpicap.com" -CSVData ([System.IO.File]::ReadAllBytes( $_.FullName)) -BadItemLimit 99999 -LargeItemLimit 99999 -SourceEndpoint "Hybrid Migration Endpoint - mail.icap.com"
}

#Create new batch with primary-only switch
Get-ChildItem E:\BatchMigrationCSVs\*.csv  | Foreach-Object{ 
New-MigrationBatch -Name ($_.Name -replace ".csv","") -PrimaryOnly -TargetDeliveryDomain "Tpicap365.mail.onmicrosoft.com" -AutoStart -AllowUnknownColumnsInCsv $true -NotificationEmails "peter.morgan@tpicap.com" -CSVData ([System.IO.File]::ReadAllBytes( $_.FullName)) -BadItemLimit 99999 -LargeItemLimit 99999 -SourceEndpoint "EMEA"
}

#Complete a migration batch -WhatIf
Get-MigrationBatch "BatchName" | Complete-MigrationBatch

#JO Complete all migration batch from csv
#::GETMOVEREQUEST
$UserCredential = Get-Credential 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection 
Import-Pssession $Session

$list=Get-Content C:\temp\o365.txt
foreach ($name in $list)
{
Get-MoveRequest -identity $name|Get-MoveRequestStatistics | Format-Table displayname, percentcomplete, statusdetail >>  C:\TEMP\REPORT.TXT
}   
#JO Use the script below to Complete synchronization the run again script on B, to check if status is completed
 #::GETMOVEREQUEST
$UserCredential = Get-Credential 
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $UserCredential -Authentication Basic -AllowRedirection 
Import-Pssession $Session

$list=Get-Content C:\temp\o365.txt
foreach ($name in $list)
{
Get-MoveRequest $Name| Set-MoveRequest -SuspendWhenReadyToComplete:$False -PreventCompletion:$False -CompleteAfter 1 
}   

#Complete an individual mailbox in a batch https://practical365.com/exchange-server/completing-individual-move-requests-migration-batch/
Get-MoveRequest [name] | Set-MoveRequest -SuspendWhenReadyToComplete:$False -PreventCompletion:$False -CompleteAfter 1 
 