$sidReference = Get-Mailbox "Drew Hobbs" | Get-ADPermission | where { ($_.ExtendedRights -like "*send-as*") -and -not ($_.user -like "Nt auth*" -or $_.user -like "*bes*" -or $_.user -like "*unitymssa*" -or $_.User -like "*goodadmin" -or $_.user -like "*svcgbexmanager" -or $_.user -like "*$samName") } | select -ExpandProperty User, PrimarySmtpAddress
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