USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_LateRefreshKPI2]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 

CREATE VIEW [dbo].[vwAppSrv_LateRefreshKPI2] AS 

WITH JiraLateExpanded AS (
	 SELECT c.Project, runs.[key], issueSource = MAX(issues.Source)
								FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
								JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_FULL
											UNION
											SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_Daily
								) runs
									ON runs.Project = c.JIRAProject
								LEFT JOIN 
								(SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
											UNION
											SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
									) issues
									ON runs.Project = issues.Project
										AND issues.Source <> 'Shyft'
										AND convert(date,runs.created) = convert(date,issues.created) 
								WHERE  runs.Project = c.JIRAProject 
									--AND runs.Status = 'Done'
									AND runs.OnTime = 'No'
									--AND CASE WHEN Updated = '[empty]' THEN NULL ELSE CAST(LEFT(runs.Updated,10) AS DATE) END  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date)
									--AND CAST(Updated AS DATE)  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date)
									AND CAST( runs.Created  AS DATE)  >= CAST( DATEADD(dd, -7 ,GETDATE()) AS Date) 
				GROUP BY c.Project, runs.[key]
)
SELECT 
	Customer = project 
	, [key]
	, c7dLateRefreshesNonSHYFT = CASE WHEN issueSource <> 'SHYFT' THEN 1 ELSE 0 END
	, c7dLateRefreshesSHYFT = CASE WHEN issueSource IS NULL THEN 1 ELSE 0 END
	, Threshold = 0 
FROM JiraLateExpanded 
 
GO
