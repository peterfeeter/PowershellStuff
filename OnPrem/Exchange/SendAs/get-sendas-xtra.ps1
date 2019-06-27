Set-ADServerSettings -ViewEntireForest $true
$mailboxes = Get-Content C:\temp\test-sendas-email-xtra.csv

foreach ($mailbox in $mailboxes)
{
    Get-Mailbox $mailbox | Select-Object Name, PrimarySmtpAddress 
}
