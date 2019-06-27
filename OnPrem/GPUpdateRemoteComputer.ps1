#Gets computers to run on from text file
#$computers = Get-Content '\\FileShare\Computers.txt'

foreach ($Computer in $Computers) 
{
$computer
Invoke-GPUpdate -Computer $Computer -RandomDelayInMinutes 0 -Sync
}