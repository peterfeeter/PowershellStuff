#Get soft-delete\disconnected mailboxes
Get-MailboxDatabase | Get-MailboxStatistics | where {$_.DisconnectReason -ne $null} | ft displayname,database,disconnectreason, disconnectdate -auto

Get-MailboxDatabase | Get-MailboxStatistics | where {$_.DisconnectReason -ne $null} | select displayname,database,server,disconnectreason, disconnectdate | sort disconnectdate | ft -auto

#To see inbox rules
Get-ICAPInboxRule -Mailbox thomas.crosthwaite@icap.com 
Get-InboxRule -Mailbox jonathan.ray@tpicap.com | fl
Get-InboxRule -Mailbox Dan.Lago@us.icap.com |  Export-csv C:\temp\DLago_rules.csv -NTI
Get-InboxRule -Mailbox Alex.Agha@icap.com | where {$_.Description -like "*hotmail*"} | fl

#To see out of office
Get-MailboxAutoReplyConfiguration -Identity c_ladde 
