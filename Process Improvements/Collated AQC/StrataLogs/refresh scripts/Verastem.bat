 powershell.exe -file d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROVER10DB1" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedErroredAQC" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "VER.vwCollatedErroredAQC" -Truncate
 powershell.exe -file d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROVER10DB1" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedQAResults" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "VER.vwCollatedQAResults" -Truncate
 powershell.exe -file  d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROVER10DB1" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedScenarios" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "VER.vwCollatedScenarios" -Truncate
 powershell.exe -file  d:\users\syue\Desktop\stratalogs\CopySQLTablev2.ps1 -SrcServer "PROVER10DB1" -SrcDatabase "TPS_DBA" -SrcSQL "SELECT * FROM dbo.vwCollatedTopTenQAResults" -DestServer "PROSHFASDB1" -DestDatabase "StrataLogs" -DestTable "VER.vwCollatedTopTenQAResults"  -Truncate