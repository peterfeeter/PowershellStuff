/* Run this in Log Parser Studio with the source as SMTPReceive files using EELLOG type, and specify the remoteIP you want to analyse by recipient address */

SELECT 
EXTRACT_PREFIX(remote-endpoint,0,':') as RemoteIP,
data,
Count(*) as Hits 
from '[LOGFILEPATH]' 
WHERE RemoteIP = '10.1.26.104'
AND data LIKE '%RCPT TO%'
GROUP BY RemoteIP, data
ORDER BY Hits DESC