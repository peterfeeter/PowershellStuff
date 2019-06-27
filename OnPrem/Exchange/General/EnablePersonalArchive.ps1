if ( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null )
{
Add-PSSnapIn Microsoft.Exchange.Management.PowerShell.E2010
}

$data = import-csv c:\temp\users.csv

#ForEach ($user in $data) {
#        
#        $Mailbox = get-mailbox $user.name
#            
#        enable-mailbox $Mailbox.UserPrincipalName -RemoteArchive -ArchiveDomain Tpicap365.mail.onmicrosoft.com
#        
#        }

ForEach ($user in $data) {
        
        
                   
        get-mailbox (get-mailbox $user.name) | select Displayname,archivename,archivedomain

        }