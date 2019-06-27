/* Run this in Log Parser Studio with the source as SMTPReceive files using EELLOG type */

SELECT 
connector-id,
EXTRACT_PREFIX(remote-endpoint,0,':') as RemoteIP,
REVERSEDNS(EXTRACT_PREFIX(remote-endpoint,0,':')) as RemoteName,
Count(*) as Hits 
from '[LOGFILEPATH]' 
WHERE data LIKE '%EHLO%' 
GROUP BY connector-id, RemoteIP 
ORDER BY Hits DESC