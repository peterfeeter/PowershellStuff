# Declare an empty array to hold the output
$Output = @()

# Declare a custom PS object. This is the template that will be copied multiple times. 
# This is used to allow easy manipulation of data from potentially different sources
$TemplateObject = New-Object PSObject | Select-Object DisplayName, AllowedDeviceIDs

# Capture the current time information.
$DeviceAgelimit = (Get-Date).AddDays(-30)

Write-Host "Processing devices that have synched after: $DeviceAgelimit" -ForegroundColor Green # Enable for debugging
Write-Host 

# Firstly get a list of all mailboxes that have one or more ActiveSync devices associated with them
$EASMailboxes = Get-CASMailbox -Filter {hasactivesyncdevicepartnership -eq $true -and -not displayname -like "CAS_{*"} -ResultSize Unlimited;
#Or, import from existing CSV those devices where you want to individually allow
#$EASMailboxes = Get-Content C:\pathtocsv.csv

# Step through each mailbox and process the devices that are currently in use  
FOREACH ($EASMailbox in $EASMailboxes)
{    # Make a copy of the TemplateObject.  Then work with the copy...
    $WorkingObject = $TemplateObject | Select-Object * 

    Write-Host "Processing Mailbox: $EASMailbox" -ForegroundColor  Magenta 
    Write-Host 
        # Create null array to store current user's devices
        $EASDeviceIDs = @() 
        # Creat null array to store current user's device statistics.  Needed to work out devices that have connected in the specified time period.
        # Initialise it to zero for each user 
        $EASDevices = @()

        # Retrieve the ActiveSync Device Statistics for the associated user mailbox.  This may be multivalued, hence is stored in an array.  
        # Need to se the .identity attribute else Get-ActiveSyncDeviceStatistics will not have the expected input object and you will get the below error. 
        # Cannot process argument transformation on parameter 'Mailbox'. Cannot convert the "Tailspintoys.ca/Users/user-50" value of type "Deserialized.Microsoft.Exchange.Data.Directory.Management.CASMailbox" to type 
        # "Microsoft.Exchange.Configuration.Tasks.MailboxIdParameter".
        # + CategoryInfo          : InvalidData: (:) [Get-ActiveSyncDeviceStatistics], ParameterBindin...mationException
        # + FullyQualifiedErrorId : ParameterArgumentTransformationError,Get-ActiveSyncDeviceStatistics
        # + PSComputerName        : tail-exch-1.tailspintoys.ca

        $EASDevices = Get-ActiveSyncDeviceStatistics -Mailbox $EASMailbox.Identity 
        
        # Use the information retrieved above to store information one by one about each ActiveSync Device
        FOREACH ($EASDevice in $EASDevices)
        {
            # Write-Host "Processing Device: " $EASDevice.DeviceID " Last Sync Time:" $EASDevice.LastSuccessSync  # Enable for debugging 
            # Logic to carry over or discard particular devices.  
            # First item to evaluate is LastSuccessSync
            IF  ($DeviceAgelimit -LT $EASDevice.LastSuccessSync)
            {
                   Write-Host "DeviceID: " $EASDevice.DeviceID " has synchronised in the last 30 days, on " $EASDevice.LastSuccessSync
                        $EASDeviceIDs += $EASDevice.DeviceID
            }
        }
        Write-Host "For User: $EASMailbox Found " ($EASDeviceIDs).count " EAS Devices" 

      # Write the collection of devices as allowed for the given user 
      Set-CasMailbox $EASMailbox.Identity -ActiveSyncAllowedDeviceIDs $EASDeviceIDs

    # Build me up buttercup
    # Populate the TemplateObject with the necessary details.
    $WorkingObject.DisplayName      = $EASMailbox
    $WorkingObject.AllowedDeviceIDs =  $EASDeviceIDs
      
    # Display output to screen.  REM out if not reqired/wanted 
    # $WorkingObject
    # Append  current results to final output
    $Output += $WorkingObject
}

Write-host
Write-Host
Write-host "Processing complete" 
Write-Host 
# Echo to screen
$Output
# Or output to a file.  The below is an example of going to a CSV file
# The Output.csv file is located in the same folder as the script. This is the $PWD or Present Working Directory. 
$Output | Export-Csv -Path $PWD\Output.csv -NoTypeInformation






<# 
.SYNOPSIS
	Purpose of this script to to assist when changing the default Exchange 2010/2013 ActiveSync DefaultAccessLevel setting from it's default value of Allow to either Quarrantined or Blocked.
    This is an issue as devices which were allowed in, will be blocked or quarantined if there are no other device rules that permit them to connect to Exchange.  

    One way is to create all of the device rules in advance, prior to making this change.  

    Another is to get a listing of all the ActiveSync Devices and grandfather existing devices in.  
    This is the purpose of this script. All devices will be considered as valid, and will be set as allowed.  No exceptions. 
    Be sure to understand this, and test in your lab prior to running in production.  

.DESCRIPTION
	
    This is to grandfather in *ALL* existing devices. 

    Script will consider devices that are synchronising in the last 30 days as valid.  
    If a device has not synchronised in this timeperiod it is not carried over.

    You can change the timespan if needed to suit your business requirements.  

    See this blog post for more details:
    http://blogs.technet.com/b/rmilne/archive/2015/02/25/exchange-activesync-script-to-grandfather-existing-devices.aspx

    You may want to filter out any CAS Test  mailboxes
    CAS test mailboxes are created when the in-box script new-TestCasConnectivityUser.ps1 has been executed and then the Test-ActiveSyncConnectivity was used to verify Exchange at some point
    However if you choose to do this, then the Test-ActiveSyncConnectivity cmdlets will fail as device type that the cmdlet uses will be blocked.  

    An example of a test device would be the following from Get-CASMailbox: 

    SamAccountName    : extest_4ca5fda1c3994
    ServerName        : tail-ca-exch-2
    DisplayName       : extest_4ca5fda1c3994
    Name              : extest_4ca5fda1c3994
    DistinguishedName : CN=extest_4ca5fda1c3994,CN=Users,DC=Tailspintoys,DC=ca

.ASSUMPTIONS
    Script is being executed from an existing Exchange Management Shell sesion.
	Script is being executed with sufficient permissions to access Exchange.
	You can live with the Write-Host cmdlets :) 
	You can add your error handling if you need it.  

#>