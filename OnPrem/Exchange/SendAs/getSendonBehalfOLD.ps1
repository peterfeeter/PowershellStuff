<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.99
	 Created on:   	10/10/2017 14:30
	 Created by:   	 Omprakash.Srivastava
	 Organization: 	ICAP
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
Set-ADServerSettings -ViewEntireForest $true
$mailboxes = Get-Mailbox -ResultSize unlimited | where {$_.grantsendonbehalfto -ne $null -and $_.distinguishedName -notlike "*newco migrated*"}
$count = 1
$totalCount = $mailboxes.count
foreach ($mailbox in $mailboxes)
{
	Write-Progress -Activity "Gathering Information" -Status "Percent Complete $count/$totalCount" -PercentComplete ($count/$totalCount * 100)
	$count++
	
	$grantSendonBehalf = $mailbox | select -ExpandProperty grantsendonbehalfto
	$samAccountName = $mailbox.samAccountName
	
	foreach ($sendonbehalfto in $grantSendonBehalf)
	{
		$sendonbehalf = Get-Mailbox $sendonbehalfto.DistinguishedName
		
		$obj = New-Object System.Management.Automation.PSObject
		$obj | Add-Member NoteProperty Name $mailbox.name
		$obj | Add-Member NoteProperty SMTP $mailbox.PrimarySMTPAddress
		$obj | Add-Member NoteProperty SamAccountName $samAccountName
		$obj | Add-Member NoteProperty GrantSendOnBehalfTo $sendonbehalfto.name
		$obj | Add-Member NoteProperty GrantSendOnBehalfToSamName $sendonbehalf.samAccountName
		$obj | Add-Member NoteProperty GrantSendOnBehalfToSMTP $sendonbehalf.PrimarySMTPAddress
		$obj | Add-Member NoteProperty GrantSendOnBehalfUserDomain $sendonbehalfto.DomainId
		$obj | Add-Member NoteProperty GrantSendOnBehalfDN $sendonbehalfto.DistinguishedName
		
		Write-Output $obj
		
		$sendonbehalf = $null
	}
}