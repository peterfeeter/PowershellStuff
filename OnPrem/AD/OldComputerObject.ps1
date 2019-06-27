#Identifies and ages out computers that have not contacted AD
#Set date threshold
$date = (get-date).adddays(-90)
#Log to file section
#code here#

#Get old computer objects
Get-Adcomputer -Server LDNPINFDCE01.eur.ad.tullib.com -filter {(passwordlastset -lt $date) -and (operatingsystem -like "*server*")} -properties DistinguishedName,passwordlastset, OperatingSystem | select name, passwordlastset, OperatingSystem,DistinguishedName | sort passwordlastset,DistinguishedName | ft -auto
#$oldmachinescount.Count
$oldmachines = Get-AdComputer -Server LDNPINFDCE01.eur.ad.tullib.com  -filter {passwordlastset -lt $date} -properties passwordlastset

get-ADComputer $oldmachines | Disable-ADAccount | Move-ADObject -TargetPath "OU=Disabled Objects,DC=eur,DC=ad,DC=tullib,DC=com" -recursive -verbose -confirm:$false

#Email notification
#code here#