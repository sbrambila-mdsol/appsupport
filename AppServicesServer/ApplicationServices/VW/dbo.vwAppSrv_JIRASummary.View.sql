USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_JIRASummary]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










 


CREATE VIEW [dbo].[vwAppSrv_JIRASummary] AS 

WITH JiraSummary AS (
	SELECT c.Project, c.JIRAProject
	, c7dRefreshes = (SELECT COUNT(runs.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_Daily
							) runs
							WHERE  runs.Project = c.JIRAProject 
								AND runs.Status = 'Done'
								AND CASE WHEN ResolutionDate = '[empty]' THEN NULL ELSE CAST(LEFT(runs.ResolutionDate,10) AS DATE) END  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date)
								AND CAST(Created  AS Date) >= CAST( DATEADD(dd,-14,GETDATE()) AS Date)
							)
	, c7dLateRefreshes = (SELECT COUNT(runs.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_Daily
							) runs
							WHERE  runs.Project = c.JIRAProject 
								--AND runs.Status = 'Done'
								AND runs.OnTime = 'No'
								--AND CASE WHEN Updated = '[empty]' THEN NULL ELSE CAST(LEFT(runs.Updated,10) AS DATE) END  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date)
								--AND CAST(Updated AS DATE)  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date)
								AND CAST( Created  AS DATE)  >= CAST( DATEADD(dd, -7 ,GETDATE()) AS Date) 
							) 
	, c7dProductionIssues = (SELECT COUNT(issues.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
								) issues
							WHERE  issues.Project = c.JIRAProject  
								AND CAST(issues.Created AS datetime)  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date)
								AND [ProdIssueRootCause] <> 'Not an Issue' 
							)
	, p7dProductionIssues = (SELECT COUNT(issues.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
								) issues
							WHERE  issues.Project = c.JIRAProject  
								AND CAST(issues.Created AS datetime) BETWEEN   DATEADD(dd,-14,GETDATE()) AND CAST( DATEADD(dd,-7,GETDATE()) AS Date)
								AND [ProdIssueRootCause] <> 'Not an Issue' 
							)
	, c13wProductionIssues = (SELECT COUNT(issues.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
								) issues
							WHERE  issues.Project = c.JIRAProject  
								AND CAST(issues.Created AS datetime)  >= CAST( DATEADD(ww,-13,GETDATE()) AS Date)
								AND [ProdIssueRootCause] <> 'Not an Issue' 
							)
	, c7dCustomerFacingIssues = (SELECT COUNT(issues.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
								) issues
							WHERE  issues.Project = c.JIRAProject  
								AND CAST(issues.Created AS datetime)  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date)
								AND issues.Client_Facing = 'Yes'
								AND [ProdIssueRootCause] <> 'Not an Issue' 
							)
	, p7dCustomerFacingIssues = (SELECT COUNT(issues.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
								) issues
							WHERE  issues.Project = c.JIRAProject  
								AND CAST(issues.Created AS datetime) BETWEEN   DATEADD(dd,-14,GETDATE()) AND CAST( DATEADD(dd,-7,GETDATE()) AS Date)
								AND issues.Client_Facing = 'Yes'
								AND [ProdIssueRootCause] <> 'Not an Issue' 
							)
	, c7dSHYFTIssues = (SELECT COUNT(issues.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
								) issues
							WHERE  issues.Project = c.JIRAProject  
								AND CAST(issues.Created AS datetime)  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date) 
								AND [ProdIssueRootCause] <> 'Not an Issue' 
								AND [ProdIssueRootCause] LIKE '%SHYFT%'
							)
	, c7dnonSHYFTIssues = (SELECT COUNT(issues.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
								) issues
							WHERE  issues.Project = c.JIRAProject  
								AND CAST(issues.Created AS datetime)  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date) 
								AND [ProdIssueRootCause] <> 'Not an Issue' 
								AND [ProdIssueRootCause] NOT LIKE '%SHYFT%'
							)
	, OpenProductionIssues = (SELECT COUNT(issues.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
								) issues
							WHERE  issues.Project = c.JIRAProject  
								AND Status <> 'Done' 
							) 
	, c1moplusOpenProductionBugs = (SELECT COUNT(bugs.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdBugTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdBugTickets_Daily
								) bugs
							WHERE  bugs.Project = c.JIRAProject  
								AND Client_Facing = 'Yes'
								AND (Status <> 'Done' OR CAST(bugs.Created AS datetime)  >= CAST( DATEADD(mm,-1,GETDATE()) AS Date) ) 
							) 
	, p1moplusOpenProductionBugs = (SELECT COUNT(bugs.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdBugTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdBugTickets_Daily
								) bugs
							WHERE  bugs.Project = c.JIRAProject  
								AND Client_Facing = 'Yes'
								AND (Status <> 'Done' OR CAST(bugs.Created AS datetime)  BETWEEN CAST( DATEADD(mm,-2,GETDATE()) AS Date) AND CAST( DATEADD(mm,-1,GETDATE()) AS Date) ) 
							) 
	FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
), CustomerMask AS (
	SELECT Project, CustomerMaskName = 'Customer ' + CAST(ROW_NUMBER() OVER (ORDER BY Project) AS VARCHAR(10))
	FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
	GROUP BY Project
)
SELECT 
	Customer = CASE WHEN AGD.udfGetSetting('MaskCustomerName') = '0' THEN Project ELSE (SELECT CustomerMaskName FROM CustomerMask WHERE JiraSummary.Project = CustomerMask.Project )END
	, projectcount = CASE WHEN AGD.udfGetSetting('MaskCustomerName') = '0' THEN 1 ELSE NULL END 
	, c7dRefreshes = SUM(c7dRefreshes)
	, c7dLateRefreshes = SUM(c7dLateRefreshes)
	, LateRefreshThreshold = 0
	, c7dProductionIssues = SUM(c7dProductionIssues)
	, p7dProductionIssues = SUM(p7dProductionIssues)
	, c7dCustomerFacingIssues = SUM(c7dCustomerFacingIssues)
	, p7dCustomerFacingIssues = SUM(p7dCustomerFacingIssues)
	, c7dSHYFTIssues = SUM(c7dSHYFTIssues)
	, c7dnonSHYFTIssues = SUM(c7dnonSHYFTIssues)
	, OpenProductionIssues = SUM(OpenProductionIssues)
	, c1moplusOpenProductionBugs = SUM(c1moplusOpenProductionBugs)
	, p1moplusOpenProductionBugs = SUM(p1moplusOpenProductionBugs)
	, OpenIssuesThreshold = 0 
	, c13wProductionIssues = SUM(c13wProductionIssues)
	, avg13wProductionIssues = CEILING(SUM(c13wProductionIssues)/13.0)
	, projectorderOverride = CASE WHEN Project LIKE '%Janssen%' THEN 999
								  WHEN Project LIKE '%Immunomedics%' THEN 999
										 ELSE 0 END
FROM JiraSummary
GROUP BY Project
 
GO
