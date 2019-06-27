<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.99
	 Created on:   	29/09/2017 11:55
	 Created by:   	 Omprakash.Srivastava
	 Organization: 	ICAP
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

if ( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null )
{
Add-PSSnapIn Microsoft.Exchange.Management.PowerShell.E2010
}

function Translate-SID($sid)
{
	$objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
	$objUser = $objSID.Translate([System.Security.Principal.NTAccount])
	return $objUser.Value
}

$mailboxes = Get-Content D:\Scripts\Send-AS\mailboxes.txt
$count = 1
$totalCount = $mailboxes.count
foreach ($mailbox in $mailboxes)
{
	
	
	$samName = (Get-Mailbox $mailbox).samAccountName
	Write-Progress -Activity "Gathering Information $mailbox" -Status "Percent Completed $count/$totalCount" -PercentComplete ($count/$totalCount * 100)
	$count++
	
	$sidReference = Get-Mailbox $mailbox | Get-ADPermission | where { ($_.ExtendedRights -like "*send-as*") -and -not ($_.user -like "Nt auth*" -or $_.user -like "*bes*" -or $_.user -like "*unitymssa*" -or $_.User -like "*goodadmin" -or $_.user -like "*svcgbexmanager" -or $_.user -like "*$samName") } | select -ExpandProperty User
	foreach ($sid in $sidReference)
	{
		
		#Write-Host $sid
		#convert SID to samName
		#$sendAS = Translate-SID -sid $sid
		
		#get smtp address of sid
		$user = $sid -split "\\"
		$user = $user[1]
		
		$mbx = Get-Mailbox $user
		
		$obj = New-Object System.Management.Automation.PSObject
		$obj | Add-Member NoteProperty email $mailbox
		$obj | Add-Member NoteProperty SendAs $sid
		$obj | Add-Member NoteProperty SendAsSMTP $mbx.PrimarySMTPAddress
		
		Write-Output $obj
		
		$user = $null
		
		$mbx = $null
		
	}
	
	$samName = $null
	
	
}