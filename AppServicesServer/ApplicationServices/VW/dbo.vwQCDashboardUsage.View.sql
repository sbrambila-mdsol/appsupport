USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwQCDashboardUsage]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/****** Script for SelectTopNRows command from SSMS  ******/

CREATE VIEW [dbo].[vwQCDashboardUsage] AS 
SELECT 
	DateUsed
	,username
	,Name AS 'ReportName'
	,Usage
FROM 
(
		SELECT DateUsed = CAST(TimeStart AS DATE) , Username = REPLACE(UserName, 'TPSINTERNAL\',''), c.Name, Usage = 1
		  FROM [ReportServer].[dbo].[ExecutionLogStorage] a 
		  JOIN ReportServer.dbo.Catalog c ON a.ReportID = c.ItemID
		  where username <> 'TPSINTERNAL\bosdashboards' 
			AND c.Name IN ('Master QC Dashboard', 'Client Warn and Fail QC Report')
		  group by CAST(TimeStart AS DATE) , REPLACE(UserName, 'TPSINTERNAL\',''), c.Name
  ) a
   
GO
