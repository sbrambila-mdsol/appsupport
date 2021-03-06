USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_JIRAc7dIssues_IdentifiedBy]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[vwAppSrv_JIRAc7dIssues_IdentifiedBy] AS 

SELECT 
	c.Project AS Customer
	, Identified_By
	, COUNT(issues.[Key]) AS IssuesCount
FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
		UNION
		SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
)issues
	ON c.JIRAProject = issues.Project
	AND CAST(issues.Created AS datetime)  >= CAST( DATEADD(dd,-7,GETDATE()) AS DATE)
	AND [ProdIssueRootCause] <> 'Not an Issue' 
GROUP BY c.Project, Identified_By





 
GO
