$BginfoDir = (Join-Path $env:LOCALAPPDATA "ICAP\BGInfo")
$BgiFile = "Generic.bgi"

if (!(Test-Path -Path $BginfoDir)) {
    [System.IO.Directory]::CreateDirectory($BginfoDir)
}



if (Get-WmiObject -Class "Win32_ComputerSystem" -Filter "Model = 'HVM domU'") {
    Set-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\Amazon\EC2Config" -Name "Ec2WallpaperInfoUrl" -Value 0
    $BgiFile = "AWS.bgi"
    $WebClient = New-Object System.Net.WebClient
    $InstanceId = $WebClient.DownloadString("http://169.254.169.254/latest/meta-data/instance-id")
    $DefaultRegion = $WebClient.DownloadString("http://169.254.169.254/latest/meta-data/placement/availability-zone").TrimEnd("a").TrimEnd("b")
    $IamRole = $WebClient.DownloadString("http://169.254.169.254/latest/meta-data/iam/security-credentials")
    Set-DefaultAWSRegion $DefaultRegion
    $Username = "GLOBAL\srvcsGATEAutomation" 
    $Password = "VB5cript" | ConvertTo-SecureString -asPlainText -Force
    $Credentials = New-Object System.Management.Automation.PSCredential($Username, $Password)
    Set-AWSProxy -Hostname scansafevip.uk.icap.com -Port 8080 -Credential $Credentials
    [System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2InstanceId.txt"), $InstanceId)
    [System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2IamRole.txt"), $IamRole)
    [System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2InstanceType.txt"), $WebClient.DownloadString("http://169.254.169.254/latest/meta-data/instance-type"))
    [System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2InstanceAz.txt"), $WebClient.DownloadString("http://169.254.169.254/latest/meta-data/placement/availability-zone"))
    [System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2InstanceSecurityGroups.txt"), $WebClient.DownloadString("http://169.254.169.254/latest/meta-data/security-groups").Replace("`n", "`r`t"))
    [System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2TagPID.txt"), (Get-EC2Tag | Where-Object {($_.Key -eq "PID") -and ($_.ResourceID -eq $InstanceId)}).Value)
    #[System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2TagbusinessOwner.txt"), (Get-EC2Tag | Where-Object {($_.Key -eq "businessOwner") -and ($_.ResourceID -eq $InstanceId)}).Value)
    [System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2TagEnvironment.txt"), (Get-EC2Tag | Where-Object {($_.Key -eq "Environment") -and ($_.ResourceID -eq $InstanceId)}).Value)
    [System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2TagName.txt"), (Get-EC2Tag | Where-Object {($_.Key -eq "Name") -and ($_.ResourceID -eq $InstanceId)}).Value)
    #[System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2TagserviceName.txt"), (Get-EC2Tag | Where-Object {($_.Key -eq "serviceName") -and ($_.ResourceID -eq $InstanceId)}).Value)
    #[System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2TagsupportOwner.txt"), (Get-EC2Tag | Where-Object {($_.Key -eq "supportOwner") -and ($_.ResourceID -eq $InstanceId)}).Value)
    $Document = $WebClient.DownloadString("http://169.254.169.254/latest/dynamic/instance-identity/document") | ConvertFrom-Json
    $AccountName = "Unknown"

    switch ($Document.accountId) {
        "475500628881" {$AccountName = "icap-voice"}
        "558815501378" {$AccountName = "icap-lab"}
        "707651310077" {$AccountName = "icap-fusion"}
    }

    [System.IO.File]::WriteAllText((Join-Path $BginfoDir "Ec2accountId.txt"), "$AccountName ($($Document.accountId))")
}


if ((Get-WmiObject -Class "Win32_OperatingSystem").Version -like "6.1*") {
    $BgiFile = "Win2008_$BgiFile"
}
elseif ((Get-WmiObject -Class "Win32_OperatingSystem").Version -like "10.0*") {
    $BgiFile = "Win2016_$BgiFile"
}
else {
    $BgiFile = "Win2012_$BgiFile"
}

Invoke-WebRequest -Uri "http://blox.corp.ad.tullib.com/BGInfo/$BgiFile" -OutFile (Join-Path $BginfoDir $BgiFile)

#this block of code parses a json file and breaks it into text files for bginfo to read
#CHG0050591
new-item -path "C:\A2RM_CMDB" -itemtype directory -erroraction:ignore
cd C:\A2RM_CMDB
$json = get-content .\a2rm_cmdb.json | ConvertFrom-Json
new-item -path .\for-bginfo -itemtype directory -erroraction:ignore 
cd .\for-bginfo
Get-ChildItem *.txt | Remove-Item
$json.psobject.properties | %{
$name = $_.name
$value = $_.value
new-item -path .\$name.txt
set-content -path .\$name.txt -Value $value
}


if (Test-Path -Path (Join-Path $BginfoDir $BgiFile)) {
    Start-Process -FilePath "C:\Program Files (x86)\Sysinternals\BGInfo\bginfo.exe" -ArgumentList "`"$(Join-Path $BginfoDir $BgiFile)`" /timer:0"
}


