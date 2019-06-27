#Gets computers to run on from text file
#$computers = Get-Content '\\fileshare\Computers.txt'

#Name of process to find
$ProcessName = "notepad"

ForEach ($Computer in $Computers)
 {
 $Computer
 get-process -ComputerName $Computer -Name $ProcessName
 }