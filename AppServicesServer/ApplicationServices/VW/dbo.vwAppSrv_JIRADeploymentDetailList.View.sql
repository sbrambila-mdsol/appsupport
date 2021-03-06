USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_JIRADeploymentDetailList]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










 

CREATE VIEW [dbo].[vwAppSrv_JIRADeploymentDetailList] AS 

		-- Today
		SELECT 
			FilterValue = 'Today'
			,FilterOrder = 1
			,c.Project
			,[Key]
			,[Summary]
			  ,[Status]
			  ,[Status1] = 0
			  ,[Status2] = CASE WHEN [Status]='DONE' THEN 1 ELSE -1 END
			  ,[Created]
			  ,[Updated]
			  ,[ResolutionDate]
			  ,[Epic]
			  ,[IssueFree]
			  ,[OnTime]
			  ,[DeployEnv]
			  ,[Planned]
			  ,[Reporter]
			  ,[Assignee]
			-- SELECT * 
			FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
							JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_Daily
								) deploy
								 ON deploy.Project = c.JIRAProject   
								AND  DeployDate = CONVERT(varchar, DATEADD(dd,0,getdate()), 23) 
		UNION
		-- Tomorrow
		SELECT 
			FilterValue = CASE WHEN DATEPART(dw,GETDATE()) = 6 THEN 'Monday' ELSE 'Tomorrow' END
			,FilterOrder = 2
			,c.Project
			,[Key]
			,[Summary]
			  ,[Status]
			  ,[Status1] = 0
			  ,[Status2] = CASE WHEN [Status]='DONE' THEN 1 ELSE -1 END
			  ,[Created]
			  ,[Updated]
			  ,[ResolutionDate]
			  ,[Epic]
			  ,[IssueFree]
			  ,[OnTime]
			  ,[DeployEnv]
			  ,[Planned]
			  ,[Reporter]
			  ,[Assignee]
			-- SELECT * 
			 FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
							JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_Daily
								) deploy
								 ON deploy.Project = c.JIRAProject   
								AND  DeployDate = CONVERT(varchar, DATEADD(dd,CASE WHEN DATEPART(dw,GETDATE()) >= 6 THEN 3 ELSE 1 END,getdate()), 23) 
								
							 
		UNION
		-- Yesterday
		SELECT 
			FilterValue = 'Yesterday'
			,FilterOrder = 3
			,c.Project
			,[Key]
			,[Summary]
			  ,[Status]
			  ,[Status1] = 0
			  ,[Status2] = CASE WHEN [Status]='DONE' THEN 1 ELSE -1 END
			  ,[Created]
			  ,[Updated]
			  ,[ResolutionDate]
			  ,[Epic]
			  ,[IssueFree]
			  ,[OnTime]
			  ,[DeployEnv]
			  ,[Planned]
			  ,[Reporter]
			  ,[Assignee]
			-- SELECT * 
			 FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
							JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_Daily
								) deploy
								 ON deploy.Project = c.JIRAProject   
								AND  DeployDate = CONVERT(varchar, DATEADD(dd,-1,getdate()), 23) 
							 				 
		UNION
		-- Past Due
		SELECT 
			FilterValue = 'Not Closed'
			,FilterOrder = 4
			,c.Project
			,[Key]
			,[Summary]
			  ,[Status]
			  ,[Status1] = 0
			  ,[Status2] = CASE WHEN [Status]='DONE' THEN 1 ELSE -1 END
			  ,[Created]
			  ,[Updated]
			  ,[ResolutionDate]
			  ,[Epic]
			  ,[IssueFree]
			  ,[OnTime]
			  ,[DeployEnv]
			  ,[Planned]
			  ,[Reporter]
			  ,[Assignee]
			-- SELECT * 
			 FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
							JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_Daily
								) deploy
								 ON deploy.Project = c.JIRAProject   
								AND [Status]='In Progress'
								AND  deploydate <> '[empty]'
												 
		UNION
		-- Bad Deployment
		SELECT 
			FilterValue = '7 Day Bad Ticket'
			,FilterOrder = 5
			,c.Project
			,[Key]
			,[Summary]
			  ,[Status]
			  ,[Status1] = 0
			  ,[Status2] = CASE WHEN [Status]='DONE' THEN 1 ELSE -1 END
			  ,[Created]
			  ,[Updated]
			  ,[ResolutionDate]
			  ,[Epic]
			  ,[IssueFree]
			  ,[OnTime]
			  ,[DeployEnv]
			  ,[Planned]
			  ,[Reporter]
			  ,[Assignee]
			-- SELECT * 
			 FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
							JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_FULL WHERE DeployDate <> '[empty]'
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_Daily WHERE DeployDate <> '[empty]'
								) deploy
								 ON deploy.Project = c.JIRAProject   
								AND  IssueFree = 'No' AND CAST(DeployDate AS DATE) >= DATEADD(dd,-7, GETDATE())
								AND [Status] <> 'To Do'
															 
		UNION
		-- Late Deployment
		SELECT 
			FilterValue = '7 Day Late Ticket'
			,FilterOrder = 5
			,c.Project
			,[Key]
			,[Summary]
			  ,[Status]
			  ,[Status1] = 0
			  ,[Status2] = CASE WHEN [Status]='DONE' THEN 1 ELSE -1 END
			  ,[Created]
			  ,[Updated]
			  ,[ResolutionDate]
			  ,[Epic]
			  ,[IssueFree]
			  ,[OnTime]
			  ,[DeployEnv]
			  ,[Planned]
			  ,[Reporter]
			  ,[Assignee]
			--SELECT * 
			 FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
							JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_FULL WHERE DeployDate <> '[empty]'
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_Daily WHERE DeployDate <> '[empty]'
								) deploy
								 ON deploy.Project = c.JIRAProject   
								AND  OnTime = 'No' AND  CAST(DeployDate AS DATE) >= DATEADD(dd,-7, GETDATE())
								AND [Status] <> 'To Do'

GO
