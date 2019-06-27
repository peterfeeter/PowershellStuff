/* Run this in Log Parser Studio with the source as SMTPReceive files using EELLOG type */

SELECT 
connector-id,
Count(*) as Hits
from '[LOGFILEPATH]' 
WHERE data LIKE '%EHLO%'
GROUP BY connector-id
ORDER BY Hits DESC