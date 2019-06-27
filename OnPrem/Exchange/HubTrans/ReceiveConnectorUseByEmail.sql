/* Run this in Log Parser Studio with the source as SMTPReceive files using EELLOG type, and specify the connector you want to analyse */
SELECT 
data,
Count(*) as Hits
FROM '[LOGFILEPATH]'
WHERE connector-id = 'AU1WMSGCAS01\Default AU1WMSGCAS01'
AND data LIKE '%RCPT TO%'
GROUP BY data
ORDER BY Hits DESC