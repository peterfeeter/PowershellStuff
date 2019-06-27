function Create-MailboxReport {
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$False,Position=0)]
        [string]$CSV = "C:\temp\leavers_report.csv",
 
        [Parameter(Mandatory=$False,Position=1)]
        [int]$MaxResults = 10000,
 
        [Parameter(Mandatory=$false)]
        $ADFilter = {msExchRecipientTypeDetails -neq "NULL"},
 
        [Parameter(Mandatory=$false)]
        [bool] $ExchangeOnline = $true,
 
        [Parameter(Mandatory=$false)]
        [ValidateSet("sAMAccountName", "userPrincipalName", "DistinguishedName", "mailNickname")]
        $ExchangeIdentifierAttribute = "sAMAccountName"
    )
 
    # Different approach between on-premises Exchange and Exchange Online
    if($ExchangeOnline) {
        # If Connect-ExchangeServer is available, we are in an Exchange PowerShell. That means we cannot load the Exchange Online cmdlets.
        if(Get-Command "Connect-ExchangeServer" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue) {
            Write-Error "Sorry, you are running an Exchange PowerShell and trying to connect to Exchange Online. Please open a regular PowerShell."
            return;
        }
 
        # If Get-Mailbox already exists, there is not reason to connect again.
        if(!(Get-Command "Get-Mailbox" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)) {
            Write-Verbose "Connecting to Exchange Online"
            $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Authentication Basic -AllowRedirection -Credential (Get-Credential)
            Import-PSSession $session -DisableNameChecking
        } else {
            Write-Verbose "Already connected to Exchange Online?"
        }
    } else {
        # Load RemoteExchange if Connect-ExchangeServer is not present
        if(!(Get-Command "Connect-ExchangeServer" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue)) {
            Write-Verbose "Loading RemoteExchange"
            $remoteExchange = 'C:\Program Files\Microsoft\Exchange Server\V14\Bin\RemoteExchange.ps1'
            if(Test-Path $remoteExchange) {
                . $remoteExchange
            } else {
                Write-Error "Could not find $remoteExchange"
                return;
            }
        }
 
        Write-Verbose "Connecting to Exchange on-premises"
        Connect-ExchangeServer -Auto
    }
 
    Write-Verbose "Loading AD module"
    Import-Module ActiveDirectory -Verbose:$false
 
    Write-Verbose ("Getting max {0} users from AD matching filter: {1}" -f $MaxResults, $ADFilter)
    Write-Progress -Activity "Getting user objects from AD" -Status " " -PercentComplete 20
    $adusers = Get-ADUser -Server GB01WDSSAPP04P.icap.com:3268 -filter $ADFilter -Properties lastlogontimestamp,whencreated,DisplayName,altRecipient,msExchHideFromAddressLists,Manager,msExchDelegateListLink,msExchRecipientTypeDetails,mailNickname -ResultSetSize $MaxResults
    Write-Progress -Activity "Getting user objects from AD" -Status " " -PercentComplete 100 -Completed
 
    $inc = 1;
    $adusers | foreach{
        $AD = $_ # This makes it a bit more easy to read
        Write-Progress -Activity "Running" -Status ("{0}/{1} - {2}" -f $inc, $adusers.Count, $AD.SamAccountName) -PercentComplete ($inc / $adusers.Count * 100) ; $inc++
        Write-Debug "Getting mailbox statitics"
 
        # Get mailbox statistics for mailbox. If it fails, give warning but continue with the rest of the mailboxes.
        $MAILBOXSTATISTICS = Get-MailboxStatistics -Identity $AD.$ExchangeIdentifierAttribute -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        if(!$MAILBOXSTATISTICS) {
            Write-Warning ("Could not find mailbox statics for {0}" -f $AD.$ExchangeIdentifierAttribute )
            return;
        }
 
        # Get all mailboxe permissions that are not inherited, that is not on the form "NT AUTHORITY\SELF" and the SID is resolvable
        Write-Debug "Getting mailbox permissions"
        $MAILBOXPERMISSION = Get-MailboxPermission -Identity $AD.$ExchangeIdentifierAttribute | where{!$_.IsInherited} | where{([string]$_.User) -notlike "NT AUTH*"} | where{([string]$_.User) -notlike "S-1-5-21-*"}
        Write-Debug ("Found {0} mailbox permissions" -f ($MAILBOXPERMISSION | measure).Count)
 
        # Extract a few attributes
        $lastlogontimestamp = if($AD.lastlogontimestamp){$AD.lastlogontimestamp}else{0}
 
 
        # Create hashmap with all properties
        $properties = @{
            DisplayName = $AD.DisplayName
            sAMAccountName = $AD.SamAccountName
            RecipientType = $AD.msExchRecipientTypeDetails
            MailboxItemCount = $MAILBOXSTATISTICS.ItemCount
            MailboxTotalItemSize = $MAILBOXSTATISTICS.TotalItemSize
            MailboxLastAccessedTime = $MAILBOXSTATISTICS.LastLogonTime
            MailboxServer = $MAILBOXSTATISTICS.ServerName
            MailboxDatabase = $MAILBOXSTATISTICS.DatabaseName
            ADObjectWhenCreated = $AD.whencreated
            HiddenFromAddressListsEnabled = $AD.msExchHideFromAddressLists
            ForwardedTo = $AD.altRecipient
            LastLoggedOnUserAccount = $MAILBOXSTATISTICS.LastLoggedOnUserAccount
            Manager = $AD.Manager
            NumberOfAutomappings = ($AD.msExchDelegateListLink | measure).Count
            NumberOfDelegations = ($MAILBOXPERMISSION | measure).Count
            ADObjectLastLogonTimeStamp = [datetime]::FromFileTime($lastlogontimestamp)
            DistinguishedName = $AD.DistinguishedName
        }
 
        # Create custom object
        return New-Object -TypeName PSObject -Property $properties
    } | Export-Csv -Path $CSV -Encoding UTF8 -NoTypeInformation -Delimiter ";"
 
    Write-Progress -Activity "Running" -Status "Completed" -PercentComplete 100 -Completed
    Write-Output "$CSV created"
}