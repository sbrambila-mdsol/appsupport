 powershell.exe -file d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROULT10DB1" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedErroredAQC" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "ULT.vwCollatedErroredAQC" -Truncate
 powershell.exe -file d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROULT10DB1" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedQAResults" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "ULT.vwCollatedQAResults" -Truncate
 powershell.exe -file  d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROULT10DB1" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedScenarios" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "ULT.vwCollatedScenarios" -Truncate
 powershell.exe -file  d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROULT10DB1" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedTopTenQAResults" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "ULT.vwCollatedTopTenQAResults"  -Truncate