 powershell.exe -file d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROAMG10DB10" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedErroredAQC" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "AMG.vwCollatedErroredAQC" -Truncate
 powershell.exe -file d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROAMG10DB10" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedQAResults" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "AMG.vwCollatedQAResults" -Truncate
 powershell.exe -file  d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROAMG10DB10" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedScenarios" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "AMG.vwCollatedScenarios" -Truncate
 powershell.exe -file  d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROAMG10DB10" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedTopTenQAResults" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "AMG.vwCollatedTopTenQAResults"  -Truncate