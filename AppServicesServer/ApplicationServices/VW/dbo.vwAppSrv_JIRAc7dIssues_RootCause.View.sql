USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_JIRAc7dIssues_RootCause]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE VIEW [dbo].[vwAppSrv_JIRAc7dIssues_RootCause] AS 

SELECT 
	c.Project AS Customer
	, ProdIssueRootCause = CASE WHEN ProdIssueRootCause = '' THEN 'TBD' ELSE ProdIssueRootCause END
	, COUNT(issues.[Key]) AS IssuesCount
FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
		UNION
		SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
) issues
	ON c.JIRAProject = issues.Project
	AND CAST(issues.Created AS datetime)  >= CAST( DATEADD(dd,-7,GETDATE()) AS DATE)
	AND [ProdIssueRootCause] <> 'Not an Issue' 
	AND ProdIssueRootCause <> '' 
GROUP BY c.Project, ProdIssueRootCause 




 
GO
