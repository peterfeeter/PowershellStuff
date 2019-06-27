########
#publicFolderReport
#Copyright: Free to use, please leave this header intact
#Author: Jos Lieben (OGD)
#Company: OGD (http://www.ogd.nl)
#Script help: http://www.liebensraum.nl
#Purpose: This script will give you an inventory of your public folders including usage
########
 
$csvPath = Read-Host "Type a full path for a CSV file if you wish to export to CSV, otherwise, press enter"
Write-Host "One moment please…." -ForeGroundColor Green
$Servers = Get-PublicFolderDatabase
$Publicfolders = Get-PublicFolder -Recurse -Server $TargetServer.Server 
#$publicfolders = get-publicfolder -recurse -Identity "\"
$totalSize = 0
$output = @()
Write-Progress -Activity "Gathering data...." -PercentComplete 0 -Status "0%"
$totalToDo = $publicfolders.Count
$done = 0
Foreach($folder in $publicfolders){
try{
$done++
$percent = ($done/($publicfolders.Count))*100
}catch{$percent = 0}
Try{
 
Write-Progress -Activity "Doing things...." -PercentComplete $percent -Status "$percent% - processing $($folder.Identity)"
#EXCHANGE 2007
#$stringStart = $folder.Replicas[0].DistinguishedName.IndexOf("InformationStore,CN=")+20
#$parseString = $folder.Replicas[0].DistinguishedName.SubString($stringStart)
#$serverName = $parseString.SubString(0,$parseString.IndexOf(","))
#/EXCHANGE 2007
#EXCHANGE 2010
$serverName = $folder.OriginatingServer.domain
#/EXCHANGE 2010
$stats = Get-PublicFolderStatistics -Server $serverName -Identity $folder.Identity
$totalSize += $($stats.TotalItemSize.Value.ToMB())
$obj = New-Object PSObject
$obj | Add-Member NoteProperty folder($folder.Identity)
$obj | Add-Member NoteProperty size($stats.TotalItemSize.Value.ToMB())
$obj | Add-Member NoteProperty LastAccessTime($stats.lastAccessTime)
if($folder.MailEnabled){
$pfMailProperties = Get-MailPublicFolder -Identity $folder.Identity
$proxies = $pfMailProperties.EmailAddresses -Join ","
$obj | Add-Member NoteProperty mailEnabled("YES")
$obj | Add-Member NoteProperty emailAddresses($proxies)
}else{
$obj | Add-Member NoteProperty mailEnabled("NO")
$obj | Add-Member NoteProperty emailAddresses("NONE")
}
$perms = Get-PublicFolderClientPermission -Identity $folder.Identity -ErrorAction SilentlyContinue
$permColumn = 0
foreach($perm in $perms){
if($perm.User.ActiveDirectoryIdentity.Name){
$obj | Add-Member NoteProperty username$permColumn($perm.User.ActiveDirectoryIdentity.Name)
$permColumn++
}
}
$output += $obj
}catch{
Write-Host "$($folder.Identity) failed to get info because of $($Error[0])" -ForeGroundColor Red
}
}
 
if($csvPath){
$output | Export-CVS -Path $csvPath -Delimiter ";"
}else{
Write-Output $output
}
Write-Host "Total size of all folders: $totalSize"