USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_JIRAc7dLateDetails]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





 

CREATE VIEW [dbo].[vwAppSrv_JIRAc7dLateDetails] AS 


		SELECT 
			c.Project
			,[Key]
			,Summary
			,Status
			,Updated
			,ResolutionDate
			,Assignee
							FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
							JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_Daily
								) runs
								 ON runs.Project = c.JIRAProject 
								--AND runs.Status = 'Done'
								AND runs.OnTime = 'No'
								--AND CASE WHEN Updated = '[empty]' THEN NULL ELSE CAST(LEFT(runs.Updated,10) AS DATE) END  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date)
								--AND CAST(Updated AS DATE)  >= CAST( DATEADD(dd,-7,GETDATE()) AS Date)
								AND CAST( Created  AS DATE)  >= CAST( DATEADD(dd, -7 ,GETDATE()) AS Date) 
GO
