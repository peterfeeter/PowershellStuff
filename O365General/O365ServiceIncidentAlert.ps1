#Author: Peter Morgan
#Date modified: 17/01/2019

Import-Module o365servicecommunications
#Run powershell as user CORP\srvcinfps and then use this code to update the user and password
#Get-Credential | Export-CliXml -Path D:\Scripts\MessagingAlerts\Cred\o365_cred.xml

#Get cred and create session to O365 and get interesting service events from the last 60 mins
$credential = Import-Clixml -Path "D:\Scripts\MessagingAlerts\Cred\o365_cred.xml"
$O365ServiceSession = New-SCSession -Credential $Credential
$timespan = New-TimeSpan -Minutes -240
$When = (get-date) + $timespan
$Events = @(Get-SCEvent -SCSession $O365ServiceSession | Where-Object {($_.LastUpdatedTime -ge $When)} |
    Select-Object Id, Status, StartTime, LastUpdatedTime, EventType,
    @{n='ServiceName'; e={$_.AffectedServiceHealthStatus.servicename}},
    @{n='Message';e={$($_.Messages | sort -Descending PublishedTime |  Select-Object -First 1).MessageText}}, 
    @{n='PublishedTime';e={$($_.Messages | sort -Descending PublishedTime |  Select-Object -First 1).PublishedTime}}
    )
#Store events in file for debugging why alerts are not sending
#$DebugPath = "D:\Scripts\MessagingAlerts\debug_" + (Get-Date -Format "yyyy-MM-dd-HHmm") + ".txt"
#$Events | Out-File $DebugPath

<#
# Just for Debug Info

"$(get-date) Event's LastUpdateTime :"
Get-SCEvent -SCSession $O365ServiceSession  | select LastUpdatedTime | sort | ft -AutoSize -Wrap

"$(get-Date) : $($Events.count) Events Found after $when"
"$(get-Date) : $($Events.count) Events Found after $when" | add-content "D:\Scripts\MessagingAlerts\EventsFound.txt"
#>

#Send email alert based on output

if ($Events)
{
    $Tables = foreach ($Event in $Events)
    {
        @"
        <table>
            <tr>
                <th>Id</th>
                <th>Service Name</th>
                <th>Status</th>
                <th>Start Time</th>
                <th>Last Message Published Time</th>
            </tr>
			
            <tr>
                <td>$($Event.Id)</td>
                <td>$($Event.ServiceName)</td>
                <td>$($Event.Status)</td>
                <td>$($Event.StartTime)</td>
                <td>$($Event.PublishedTime)</td>
            </tr>
        </table>
        <table>
            <tr>
                <th>Last Message</th>
            </tr>

            <tr>
                <td>$($Event.Message)</td>
            </tr>
        </table>
        <br>
"@
 }

    $Html = @"
    <!DOCTYPE HTML>
    <html>
        <Head>
            <style>
                body {}
				table {width: 100%; }
                table, th, td  {
                    font-family: calibri,arial,verdana;
                    border: 2px solid white;
                    border-collapse: collapse;
                    background-color: #daeded;
                }
            </style>
        </head>
        <body>
           $Tables
        </body>
        Alert generated from LDNPINFADM05 where any O365 service degradation alerts were updated in last 60 minutes.
    </html>
"@

    $Splat = @{
        SmtpServer  = 'emeasmtp.eur.ad.tullib.com'
        Body        = $Html
        BodyAsHtml  = $true
        #To          = 'peter.morgan@tpicap.com'
        To          = 'GlobalMessagingAdministration@tullettprebon.com'
        From        = 'O365ServiceEvents@tpicap.com'
        Subject     = 'Office 365 Service Health Alerts'
           }
    Send-MailMessage @Splat
}


#Post to Teams channel webhook
if($Events)
{

$TargetChannel = 'https://outlook.office.com/webhook/38ad3ec1-ecf7-4a70-9e4b-cd266986ba78@7bc8ad67-ee7f-43cb-8a42-1ada7dcc636e/IncomingWebhook/38a30bc5dcd14c23b7ec56aaa9907213/870355a5-a24e-4023-b82f-8e8c3cdb0ff2'
                                             
$Notification = @"
    {
        "@type": "MessageCard",
        "@context": "https://schema.org/extensions",
        "summary": "Office 365 Notification",
        "themeColor": "0072C6",
        "title": "Office 365 Service Incident",
         "sections": [
            {
            
                "facts": [
                    {
                        "name": "Service Incident:",
                        "value": "ID"
                    },
                    {
                        "name": "Start Time:",
                        "value": "SDATETIME"
                    },
                    {
                        "name": "Last Updated:",
                        "value": "UDATETIME"
                    },
                    {
                        "name": "Service:",
                        "value": "SERVICENAME"
                    },
                     {
                        "name": "Status:",
                        "value": "STATUS"
                    },
                    {
                        "name": "Description:",
                        "value": 'MESSAGE'
                    }
                ],
                "text": "Office 365 Service Degradation"
            }
        ]
    }
"@

    ForEach ($Event in $Events) {
       $EventID = $Event.Id
       $EventStartTime = Get-Date ($Event.StartTime) -format g
       $EventLastUpdatedTime = Get-Date ($Event.PublishedTime) -format g
       $EventServiceName = $Event.ServiceName
       $EventMessage = $Event.Message | ConvertTo-Json
       $EventStatus = $Event.Status
       $NotificationBody = $Notification.Replace("ID","$EventId").Replace("SDATETIME","$EventStartTime").Replace("UDATETIME","$EventLastUpdatedTime").Replace("SERVICENAME","$EventServiceName").Replace("STATUS","$EventStatus").Replace("MESSAGE","$EventMessage")
       $Command = (Invoke-RestMethod -uri $TargetChannel -Method Post -body $NotificationBody -ContentType 'application/json')
    }
}

