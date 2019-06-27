#Setup required variables
#Need to create an API point in order to fill in the below
$baseUrl = "https://xx-api.mimecast.com"
$uri = "/api/message-finder/search"
$url = $baseUrl + $uri
$accessKey = "YOUR ACCESS KEY"
$secretKey = "YOUR SECRET KEY"
$appId = "YOUR APPLICATION ID"
$appKey = "YOUR APPLICATION KEY"

#Messagetracevariables
$from = 
$to = 

#Generate request header values
$hdrDate = (Get-Date).ToUniversalTime().ToString("ddd, dd MMM yyyy HH:mm:ss UTC")
$requestId = [guid]::NewGuid().guid
 
#Create the HMAC SHA1 of the Base64 decoded secret key for the Authorization header
$sha = New-Object System.Security.Cryptography.HMACSHA1
$sha.key = [Convert]::FromBase64String($secretKey)
$sig = $sha.ComputeHash([Text.Encoding]::UTF8.GetBytes($hdrDate + ":" + $requestId + ":" + $uri + ":" + $appKey))
$sig = [Convert]::ToBase64String($sig)
 
#Create Headers
$headers = @{"Authorization" = "MC " + $accessKey + ":" + $sig;
                "x-mc-date" = $hdrDate;
                "x-mc-app-id" = $appId;
                "x-mc-req-id" = $requestId;
                "Content-Type" = "application/json"}
 
#Create post body
$postBody = "{
                    ""data"": [
                        {
                            ""searchReason"": ""String"",
                            ""start"": ""Date String"",
                            ""end"": ""Date String"",
                            ""messageId"": ""String"",
                            ""advancedTrackAndTraceOptions"": {
                                ""from"": ""String"",
                                ""to"": ""String"",
                                ""subject"": ""String"",
                                ""senderIP"": ""String""
                            }
                        }
                    ]
                }"
 
#Send Request
$response = Invoke-RestMethod -Method Post -Headers $headers -Body $postBody -Uri $url
 
#Print the response
$response