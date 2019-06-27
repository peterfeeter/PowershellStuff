#Query if protocol logging is enabled on HT servers for send connectors and what limits are set
Get-TransportServer | Where-Object {$_.ReceiveProtocolLogMaxDirectorySize -ne "unlimited"} | Select-Object Name,ReceiveProtocol*,SendProtocol* | Format-Table -auto
Get-TransportServer "USHSEXHUBS03" | Select-Object Name,IntraOrgConnectorProtocolLoggingLevel,ReceiveProtocol*,SendProtocol*
#Increase SendProtocolLogMaxDirectorySize and ReceiveProtocolLogMaxDirectorySize to nGB (4?) on send connectors
Set-TransportServer "ushsexhubs02" -SendProtocolLogMaxDirectorySize 1GB -ReceiveProtocolLogMaxDirectorySize 1GB

#Query if protocol logging is enabled on receive connectos
Get-ReceiveConnector | Select-Object server,name,*protocollogginglevel,*Size | Sort-Object server | Format-Table -auto

#Query if protocol logging is enabled on send connectors
Get-SendConnector | Select-Object name,SourceTransportServers,*protocollogginglevel | Sort-Object -Descending protocollogginglevel | Format-Table -auto

#The above allows analysis to ensure if a server is in use using Log Parser https://practical365.com/exchange-server/using-log-parser-protocol-logs-analyze-send-connector-usage/

# Export remote IP ranges for a receive connector
Get-ReceiveConnector "UK0WMSGHUT02P\Inbound from Office 365" | Select-Object -expand remoteipranges | Export-Csv D:\Temp\remoteipranges2.csv

# Export address spaces, homeMTA server, and source servers for all send connectors in an Org
get-sendconnector | Select-Object Identity, @{Expression={$_.AddressSpaces};Label="AddressSpaces";}, Enabled,  HomeMtaServerId, @{Expression={$_.SmartHosts};Label="SmartHosts";}, SourceRoutingGroup, @{Expression={$_.SourceTransportServers};Label="SourceTransportServers";}
