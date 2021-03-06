USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_WeeklyJIRAIssue]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



 
 CREATE VIEW [dbo].[vwAppSrv_WeeklyJIRAIssue] AS


 SELECT 
	c.Project
	, WeekEnding
	, IssuesCount = SUM( ISNULL(Issues,0)) 
 FROM  [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
 JOIN (
	SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, GETDATE())), GETDATE()) AS DATE) WeekEnding
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-1,GETDATE()))), DATEADD(wk,-1,GETDATE())) AS DATE) 
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-2,GETDATE()))), DATEADD(wk,-2,GETDATE())) AS DATE) 
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-3,GETDATE()))), DATEADD(wk,-3,GETDATE())) AS DATE) 
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-4,GETDATE()))), DATEADD(wk,-4,GETDATE())) AS DATE) 
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-5,GETDATE()))), DATEADD(wk,-5,GETDATE())) AS DATE) 
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-6,GETDATE()))), DATEADD(wk,-6,GETDATE())) AS DATE) 
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-7,GETDATE()))), DATEADD(wk,-7,GETDATE())) AS DATE) 
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-8,GETDATE()))), DATEADD(wk,-8,GETDATE())) AS DATE) 
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-9,GETDATE()))), DATEADD(wk,-9,GETDATE())) AS DATE) 
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-10,GETDATE()))), DATEADD(wk,-10,GETDATE())) AS DATE) 
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-11,GETDATE()))), DATEADD(wk,-11,GETDATE())) AS DATE) 
	UNION SELECT CAST( DATEADD(dd, 7-(DATEPART(dw, DATEADD(wk,-12,GETDATE()))), DATEADD(wk,-12,GETDATE())) AS DATE) 
) Calendar ON 1=1
LEFT JOIN 
 (
	 SELECT 
		Project
		, CAST( DATEADD(dd, 7-(DATEPART(dw, [Created])), [Created]) AS DATE) [WeekEnd]
		, COUNT(DISTINCT [KEY]) AS Issues 
	 FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
		UNION
		SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
) issues 
	 WHERE  [Created] >= DATEADD(ww, -13, GETDATE())
		 AND [ProdIssueRootCause] <> 'Not an Issue' 
	 GROUP BY Project , CAST( DATEADD(dd, 7-(DATEPART(dw, [Created])), [Created]) AS DATE)
 ) issuescount ON c.JIRAProject = issuescount.Project
				AND Calendar.WeekEnding = issuescount.WeekEnd
GROUP BY c.Project, WeekEnding


GO
