USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_JIRAClientFacingDetails]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




 

CREATE VIEW [dbo].[vwAppSrv_JIRAClientFacingDetails] AS 


		SELECT 
			c.Project 
			,[Key]
			,TypeofIssue
			,Summary
			,Status
			,Client_Facing 
			,Created
			,Updated 
			,ResolutionDate
							FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
							JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
								) issues
								 ON issues.Project = c.JIRAProject  
								AND CAST(issues.Created AS datetime)  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date)
								AND Client_Facing = 'Yes' 
		UNION
		SELECT 
			c.Project
			,[Key]
			,TypeofIssue = 'Bug'
			,Summary
			,Status
			,Client_Facing 
			,Created
			,Updated 
			,ResolutionDate
							FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
							JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdBugTickets_FULL 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdBugTickets_Daily
								) bugs
								 ON bugs.Project = c.JIRAProject  
								AND (CAST(bugs.Created AS datetime)  >= CAST( DATEADD(mm,-1,GETDATE()) AS Date)  OR Status <> 'Done')
								AND Client_Facing = 'Yes' 
GO
