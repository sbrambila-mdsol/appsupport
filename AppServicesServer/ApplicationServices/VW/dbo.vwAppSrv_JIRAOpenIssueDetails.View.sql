USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_JIRAOpenIssueDetails]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 

CREATE VIEW [dbo].[vwAppSrv_JIRAOpenIssueDetails] AS 


		SELECT 
			c.Project
			,[Key]
			,Summary
			,Status
			,Client_Facing
			,Identified_By
			,Source
			,ProdIssueRootCause
			,IssuePriority 
			,Created
			,Updated
			,Resolution
			,ResolutionDate
							FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
							JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Full 
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdIssueTickets_Daily
								) issues
								 ON issues.Project = c.JIRAProject  
								AND Status <> 'Done' 
GO
