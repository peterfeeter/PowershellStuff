#Gets computers to run on from text file
$Machines = Get-Content '\\fileshare\Computers.txt'

$Service = "Printer Spooler"

Get-Service -Name $Service -ComputerName $Machines | Restart-Service