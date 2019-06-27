#Grandfather in existing devices to Allow prior to switching on org wide quarentine for native acticesync connections
#Retrieve mailboxes of users who have a connected ActiveSync Device
$CASMailboxes = Get-CASMailbox -Filter {hasactivesyncdevicepartnership -eq $true -and -not displayname -like "CAS_{*"} -ResultSize Unlimited;
# Approve each device 
foreach ($CASMailbox in $CASMailboxes)
{	# Array to store devices
	$DeviceIDs = @();
	# Retrieve the ActiveSync Device Statistics for the associated user mailbox
	[array]$ActiveSyncDeviceStatistics = Get-ActiveSyncDeviceStatistics -Mailbox $CASMailbox.Identity;
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

#Remove old active sync devices
$DevicesToRemove = Get-ActiveSyncDevice -result unlimited | Get-ActiveSyncDeviceStatistics | where {$_.LastSuccessSync -le (Get-Date).AddDays("-365")}
$DevicesToRemove | foreach-object {Remove-ActiveSyncDevice ([string]$_.Guid) -confirm:$false}
#Or
Get-ActiveSyncDevice -ResultSize unlimited| Get-ActiveSyncDeviceStatistics | where {$_.FirstSyncTime -lt (get-date).adddays(-4)} | select-object guid | Out-File C:\Temp\list.txt
Get-Content "C:\temp\ActiveSync\ASDevicesToRemove.txt" | Get-ActiveSyncDevice | Remove-ActiveSyncDevice 

#Query newly created activesync devices in last 14 days
$When = ((Get-Date).AddDays(-14)).Date
Get-ActiveSyncDevice | Where-Object {$_WhenCreated -ge $When} | Select-Object DeviceID, FriendlyName,UserDisplayName, whencreated

#Query to get device rules
Get-ActiveSyncDeviceAccessRule | Format-Table Name, Characteristic, QueryString, AccessLevel, WhenCreated -AutoSize

#Query for all devices associated with a user
Get-ActiveSyncDeviceStatistics -Mailbox CLiawan
Get-ActiveSyncDeviceStatistics -Mailbox "apac.ad.tullib.com/SHG/Users/Admin/Gao, Jian" | select Identity, Device*
Get-ActiveSyncDeviceStatistics -Mailbox "na.ad.tullib.com/United States/Texas/Houston/Energy/Users/Swallow, Michael" | select Identity, Device*

#Query to get devices associated with a devicerule
Get-ActiveSyncDevice -filter {(deviceaccessstatereason -eq 'DeviceRule') -and (devicetype -eq 'Android')} | select UserDisplayName,FirstSyncTime, DeviceAccessState,DeviceType | ft -auto

#Change a device from Global setting to individual setting Allow
Set-CASMailbox -Identity CLiawan -ActiveSyncAllowedDeviceIDs @{add='EQ4R6GHMJH6QDBR635FCV8UT60'}
Set-CASMailbox -Identity "apac.ad.tullib.com/SNG/Users/Laptop User/Miller, Curtis" -ActiveSyncAllowedDeviceIDs @{add='EFEI3NC4PT7KNEPES885DNHUD8'}

#Change a CSV of users and devices from Global to individual setting.
#This never fucking worked. I ended up using Excel to concatenate each "set-casmailbox" command line by line like a chump
$mbxdevices = Import-CSV "C:\temp\ListToIndividualAllows.csv"
foreach ($mbxdevice in $mbxdevices) {
Set-CASMailbox -Identity $mbxdevice.Identity -ActiveSyncAllowedDeviceIDs @{add=$mbxdevice.DeviceID}
}

#Change all devices from Global setting to individual setting Allow
#This never fucking worked.
Get-CASMailbox -Filter {hasactivesyncdevicepartnership -eq $true -and -not displayname -like "CAS_{*"} -ResultSize Unlimited
$DeviceIDs=@()
Get-ActiveSyncDeviceStatistics -Mailbox "dfernando" |
ForEach-Object{$DeviceIDs+=$_.DeviceID } 
Set-CasMailbox "Steve Goodman" -ActiveSyncAllowedDeviceIDs $DeviceIDs

#Org wide Device rule settings
Get-ActiveSyncOrganizationSettings | select Identity, DefaultAccessLevel, IsValid
Get-ActiveSyncDeviceAccessRule | select Identity, QueryString, accesslevel
