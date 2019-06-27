Set-ADServerSettings -ViewEntireForest $true
Get-Mailbox -ResultSize unlimited | 
Select-Object DisplayName,UserPrincipalName,PrimarySmtpAddress,RecipientTypeDetails,Department,Title,Office,State,OrganizationalUnit | 
Export-Csv -NoTypeInformation -Path c:\Temp\O365_Mbx_Details.csv