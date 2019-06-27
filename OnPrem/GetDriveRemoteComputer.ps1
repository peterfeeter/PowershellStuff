<#
.Synopsis
   Gets Disk Space of the given remote computer name
.DESCRIPTION
   Get-RemoteComputerDisk cmdlet gets the used, free and total space with the drive name.
.EXAMPLE
   Get-RemoteComputerDisk -RemoteComputerName "abc.contoso.com"
   Drive    UsedSpace(in GB)    FreeSpace(in GB)    TotalSpace(in GB)
   C        75                  52                  127
   D        28                  372                 400
#>
function Get-RemoteComputerDisk
{
    Param
    (
        $RemoteComputerName
    )

    Begin
    {
        $output="Drive `t UsedSpace(in GB) `t FreeSpace(in GB) `t TotalSpace(in GB) `n"
    }
    Process
    {
        $drives=Get-WmiObject Win32_LogicalDisk -ComputerName $RemoteComputerName -Credential $cred

        foreach ($drive in $drives){
            
            $drivename=$drive.DeviceID
            $freespace=[int]($drive.FreeSpace/1GB)
            $totalspace=[int]($drive.Size/1GB)
            $usedspace=$totalspace - $freespace
            $output=$output+$drivename+"`t`t"+$usedspace+"`t`t`t"+$freespace+"`t`t`t"+$totalspace+"`n"
        }
    }
    End
    {
        return $output
    }
}
$cred= get-credential 
Get-RemoteComputerDisk -RemoteComputerName "AU0WMSGCAS02"