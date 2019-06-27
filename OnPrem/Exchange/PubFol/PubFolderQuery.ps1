#Get all public folder statistcs
$PubFoLDBs = Get-PublicFolderDatabase
ForEach ($pubfoldb in $pubfoldbs) 
{
Get-PublicFolderStatistics -Server $pubfoldb.Server -ResultSize Unlimited | Select-Object FolderPath, AdminDisplayName, CreationTime, DatabaseName, LastAccessTime, LastModificationTime, TotalItemSize | export-csv C:\temp\UK_pubFolReport.csv -Append -NTI 
}

#Get public folder replicas
$PFTopLevel ="\"
$PFList = Get-PublicFolder -Identity $PFTopLevel -Recurse -ResultSize unlimited | select-object name, parentpath, @{name='Replicas';expression={[string]::join(";",($_.replicas))}}
$PFList | Export-Csv $ExportFile -NoTypeInformation 


$PubFoLs = Get-PublicFolder | where-object {$_.Server -like "AU*"}
ForEach ($pubfol in $pubfols) 
{
Get-PublicFolder -Server $pubfol.Server -ResultSize 1 | fl
}
Get-PublicFolder -Server "AU1WMSGMBX01" | Select-Object Name, Replicas


#THIS ONE WORKS OMG Get all public folder statistcs
Get-ICAPPublicFolderStatistics -ResultSize Unlimited| Select-Object @{Expression={$_.FolderPath};Label="FolderPath";}, @{Expression={$_.AdminDisplayName};Label="AdminDisplayName";}, @{Expression={$_.LastAccessTime};Label="LastAccessTime";}, @{Expression={$_.LastModificationTime};Label="LastModificationTime";}, @{Expression={$_.LastUserAccessTime};Label="LastUserAccessTime";},@{name="TotalItemSize (MB)"; expression={[math]::Round(($_.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),2)}} | Sort-Object TotalItemSize | Export-CSV C:\temp\pubfol2019.csv -NTI


# Get mail-enabled public folders
$Servers = Get-PublicFolderDatabase
foreach($TargetServer in $Servers)
{
    Get-PublicFolder -Recurse -Server $TargetServer.Server | where {$_.MailEnabled -eq $true} | select Name,  FolderPath, Server, PrimarySMTPaddress
}

# Get mail-enabled public folder, 
get-mailpublicfolder -identity '\APAC Compliance\Asian Bond Brokerage Report' -server 'SG0WMSGMBX01.sg.icap.com'
