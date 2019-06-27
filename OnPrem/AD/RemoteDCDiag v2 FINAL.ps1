
##################### 
#        DCDIAG     # 
##################### 
import-module activedirectory
# Variables to change per domain, the rest of the script can be left as is unless you want to get into html formatting hell
$Domain = "corp.ad.tullib.com"
$htmlpath = "D:\Scripts\DCDiagCheck\DCdiag_" + (Get-Date -Format "yyyy-MM-dd") + ".html"
$To = 'peter.morgan@tpicap.com'
$CC = ''
$From = 'DCDiagCheck@tpicap.com'
$SMTPServer = 'emeasmtp.eur.ad.tullib.com'

# Code
$DCs = Get-ADDomainController -filter * -server "$Domain"  
$AllDCs = $DCs | foreach {$_.hostname}  #| where {$_.hostname -like "LDNPINFDCG0*"}
Write-Host " ..... DCDiag ..... " -foregroundcolor green 
$AllDCDiags = @()

foreach ($DC in $AllDCs) 
{ 
Write-Host "Processing $DC" 
    $Dcdiag = (Dcdiag.exe /s:$DC) -split ('[\r\n]') 
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
         $TestName = $Null; $TestStatus = $Null;
        } 
        
      }
      $Dcdiag =$Null
     
$AllDCDiags += $Result 
} 

# Now convert CSV to html table, turns out that Outlook ignores any sytles set in the header, so the below $css is sort of ignored? Regardless I couldn't fix the comlumn widths when I had it in there so I commented out but left the code. Maybe someone better than me at html\css can fix it.
$css = @"
<style>
h1, h5, th { text-align: center; font-family: Segoe UI; }
table { margin: auto; font-family: Segoe UI; border: thin ridge grey; width: 100%; }
th { background: #0046c3; color: #fff; padding: 5 10; }
td { font-size: 11; padding: 5 20; color: #000; width="560"}
tr { background: #b8d1f3; }
tr:nth-child(even) { background: #dae5f4; }
tr:nth-child(odd) { background: #b8d1f3; }
</style>
"@

$html = $AllDCDiags | ConvertTo-Html -Body "<h1>DCDiag Report for $domain</h1>`n<h5>Generated on $(Get-Date -Format "yyyyMMdd")</h5>" #-Head $css
$html = $html -Replace ('Failed', '<font color="red">Failed</font>') 
$html = $html -Replace ('Passed', '<font color="green">Passed</font>') 
$html | Out-File $htmlpath

# Send html in email
$htmldata = Get-Content $htmlpath
$Subject = "DCDiag output - Generated for $Domain on $(Get-Date -Format 'yyyy-MM-dd') "
$hostname = $env:computername
$body = @"
    <!DOCTYPE HTML>
    <html>
        <body>
          See results of DCDiag run against $domain domain controllers. 
          <br>
          Please act upon any new failures you see. A good reference to start with is here - https://blogs.technet.microsoft.com/askds/2011/03/22/what-does-dcdiag-actually-do/  and https://rakhesh.com/windows/active-directory-troubleshooting-with-dcdiag-part-1/  
          <br>
          Some failures may be benign, for example the following checks pass or fail based on whether certain warning or critical events have been seen in the last 60 minutes. These should be investigated but may not indicate a serious service affecting issue.
          <br>
          FrsEvent, SystemLog, DFSREvent, KccEvent
          <br>
          <br>
          <!--[if (gte mso 9)|(IE)]>
        <table align="center" border="0" cellspacing="0" cellpadding="0" width="100%" bgcolor="#2b3452" style="background-color:#2b3452;">
        <tr>
        <td align="center" valign="top">
        <![endif]-->
        <table align="center" cellpadding="0" cellspacing="0" width="100%" bgcolor="#dae5f4">
            <tr>
                <td align="center" valign="top">
                <!--[if (gte mso 9)|(IE)]>
                <table align="center" border="0" cellspacing="5" cellpadding="5" width="600">
                <tr>
				<td align="center" valign="top" width="600">
				<![endif]-->
                    <table border="5" cellpadding="5" cellspacing="5" width="600" class="wrapper">
                    	<tbody>
                    		<tr>
                    			<td align="center" valign="top">
                    				$htmldata
                    			</td>
                    		</tr>
                    	</tbody>
                    </table>
                <!--[if (gte mso 9)|(IE)]>
				</td>
				</tr>
				</table>
				<![endif]-->  
                </td>
            </tr>
        </table>
        <!--[if (gte mso 9)|(IE)]>
        </td>
        </tr>
        </table>
        <![endif]-->
          <br>
          Alert generated from "$hostname": DCDiag results.
        </body>
    </html>
"@
$Subject = "DCDiag output - Generated for $Domain on $(Get-Date -Format 'yyyy-MM-dd') "
$Splat = @{
        SmtpServer  = $SMTPServer
        Body        = $body
        BodyAsHtml  = $true
        To          = $To
        From        = $From
        Subject     = $Subject
           }
Send-MailMessage @Splat
#Tidy up html file
Remove-Item -Path $htmlpath