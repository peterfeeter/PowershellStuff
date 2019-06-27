
##################### 
#        DCDIAG        # 
##################### 
$Domain = "corp.ad.tullib.com"
$DCs = Get-ADDomainController -filter * -server "$Domain"  
$LDNDCs = $DCs | where {$_.hostname -like "LDNPINFDCG03*"} | foreach {$_.hostname} 
Write-Host " ..... DCDiag ..... " -foregroundcolor green 
$AllDCDiags = @()
$FailedDCDiags = @()
$PassedDCDiags = @()

foreach ($DC in $LDNDCs) 
{ 
Write-Host "Processing $DC" 
    $Dcdiag = (Dcdiag.exe /s:$DC) -split ('[\r\n]') 
    $FailedResult = New-Object Object
    $FailedResult | Add-Member -Type NoteProperty -Name "ServerName" -Value $DC 
    $PassedResult = New-Object Object
    $PassedResult | Add-Member -Type NoteProperty -Name "ServerName" -Value $DC 
    $Result = New-Object Object 
    $Result | Add-Member -Type NoteProperty -Name "ServerName" -Value $DC 
        $Dcdiag | ForEach-Object{ 
        Switch -RegEx ($_) 
        { 
         "Starting"      { $TestName   = ($_ -Replace ".*Starting test: ").Trim() } 
         "passed test|failed test" { If ($_ -Match "passed test") {  
         $TestStatus = "Passed"  
         }  
         Else  
         {  
         $TestStatus = "Failed"  
         } } 
        } 
        If ($TestName -ne $Null -And $TestStatus -ne $Null) 
        { 
         $Result | Add-Member -Name $("$TestName".Trim()) -Value $TestStatus -Type NoteProperty -force 
        } 
        If ($TestName -ne $Null -and $TestStatus -eq "Failed")
        {
         $FailedResult | Add-Member -Name $("$TestName".Trim()) -Value $TestStatus -Type NoteProperty -force
         Write-Host "Test $TestName failed for $DC" -foregroundcolor red
         }
        If ($TestName -ne $Null -and $TestStatus -eq "Passed")
        {
         $PassedResult | Add-Member -Name $("$TestName".Trim()) -Value $TestStatus -Type NoteProperty -force
         Write-Host "Test $TestName passed for $DC" -foregroundcolor green
         $TestName = $Null; $TestStatus = $Null;  
      }
      $Dcdiag =$Null
    } 
$AllDCDiags += $Result 
$FailedDCDiags += $FailedResult 
$PassedDCDiags += $PassedResult
} 

$AllDCDiags | ft -AutoSize -Property *

$FailedDCDiags | ft -AutoSize -Property *

$PassedDCDiags | ft -AutoSize -Property *