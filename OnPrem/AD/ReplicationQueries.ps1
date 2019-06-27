#For local forest health check
Get-ADReplicationPartnerMetadata -Target * -Partition * | Select-Object Server,Partition,Partner,ConsecutiveReplicationFailures,LastReplicationSuccess,LastRepicationResult | Out-GridView



$UserCredential = Get-Credential -Username pmorgan-a@global.ipac.com -Message hi
Get-ADReplicationPartnerMetadata -Cred $UserCredential -Site "USA*" -Partition * -Scope Forest -PartnerType Both | Select-Object Server,Partition,Partner,ConsecutiveReplicationFailures,LastReplicationSuccess,LastRepicationResult | Out-GridView


Get-ADReplicationSite -Credential $UserCredential | fl

Get-ADReplicationPartnerFailure -Cred $UserCredential -Target "us.icap.com" 

Get-ADReplicationUpToDatenessVectorTable -Cred $UserCredential -Target "global.icap.com" | Out-GridView