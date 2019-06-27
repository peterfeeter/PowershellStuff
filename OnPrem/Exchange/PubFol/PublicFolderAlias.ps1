if ( (Get-PSSnapin -Name Microsoft.Exchange.Management.PowerShell.E2010 -ErrorAction SilentlyContinue) -eq $null )
{
Add-PSSnapIn Microsoft.Exchange.Management.PowerShell.E2010
}

$data = Import-csv c:\temp\pfoutput.csv

$data | ForEach-Object {Set-mailpublicfolder $_.PrimarySmtpAddress -alias:($_.Alias.replace(” “,””).replace(":","").replace(",","").replace("* ","").replace("(","").replace(")","").replace(".","").trim())}

#"WESTLB ".replace(" ","").replace(":","").replace("(","").replace(")","").replace("*.","").trim()



