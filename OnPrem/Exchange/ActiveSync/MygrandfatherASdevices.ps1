#Grandfather in existing devices to Allow prior to switching on org wide quarentine for native acticesync connections
#Retrieve mailboxes of users who have a connected ActiveSync Device
$When = ((Get-Date).AddDays(-60)).Date
$CASMailboxes = Get-CASMailbox -Filter {hasactivesyncdevicepartnership -eq $true -and -not displayname -like "CAS_{*"} -ResultSize Unlimited;
# Approve each device 
foreach ($CASMailbox in $CASMailboxes)
{	# Array to store devices
	$DeviceIDs = @();
	# Retrieve the ActiveSync Device Statistics for the associated user mailbox
	[array]$ActiveSyncDeviceStatistics = Get-ActiveSyncDeviceStatistics -Mailbox $CASMailbox.Identity | where-object {LastSuccessSync -ge "$when"};
	# Use the information retrieved above to store information one by one about each ActiveSync Device
	foreach ($Device in $ActiveSyncDeviceStatistics)
	{
		$DeviceIDs += $Device.DeviceID
	}
	#Set-CasMailbox $CASMailbox -ActiveSyncAllowedDeviceIDs $DeviceIDs
    # Display Useful Output that can be piped to Export-CSV or just shown as the script runs
    $Output = New-Object Object
	$Output | Add-Member NoteProperty DisplayName $Mailbox.DisplayName
	$Output | Add-Member NoteProperty AllowedDeviceIDs $DeviceIDs
    $Output 
}
$Output | Export-CSV C:\Temp\ASreport.csv -NTI


#Test version of the above, narrowed to 3 users who have Sony devices in order to test the foreach loop
#
#Grandfather in existing devices to Allow prior to switching on org wide quarentine for native acticesync connections
#Retrieve mailboxes of users who have a connected ActiveSync Device
$CASMailboxes = Get-CASMailbox -Filter {hasactivesyncdevicepartnership -eq $true -and -not displayname -like "CAS_{*"} -ResultSize Unlimited;
# Approve each device 
foreach ($CASMailbox in $CASMailboxes)
{	# Array to store devices
	$DeviceIDs = @();
	# Retrieve the ActiveSync Device Statistics for the associated user mailbox
	[array]$ActiveSyncDeviceStatistics = Get-ActiveSyncDeviceStatistics -Mailbox $CASMailbox.Identity  | Where-Object {$_.devicetype -like "Sony*"};}
	# Use the information retrieved above to store information one by one about each ActiveSync Device
	foreach ($Device in $ActiveSyncDeviceStatistics)
	{
		$DeviceIDs += $Device.DeviceID
	}
	Set-CasMailbox $CASMailbox -ActiveSyncAllowedDeviceIDs $DeviceIDs
    # Display Useful Output that can be piped to Export-CSV or just shown as the script runs
    $Output = New-Object Object
	$Output | Add-Member NoteProperty DisplayName $Mailbox.DisplayName
	$Output | Add-Member NoteProperty AllowedDeviceIDs $DeviceIDs
    $Output 
}
$Output | Export-CSV C:\Temp\ASreport.csv -NTI

Get-CASMailbox Chris.Boyce@tpicap.com | 
Get-ActiveSyncDeviceStatistics -Mailbox Chris.Boyce@tpicap.com | Where-Object {$_.devicetype -like "Sony*"}

Get-ActiveSyncDeviceStatistics -Mailbox * | Where-Object {$_.devicetype -like "Sony*"}