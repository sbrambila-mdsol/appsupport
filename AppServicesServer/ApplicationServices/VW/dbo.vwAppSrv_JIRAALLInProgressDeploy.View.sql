USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_JIRAALLInProgressDeploy]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




 

CREATE VIEW [dbo].[vwAppSrv_JIRAALLInProgressDeploy] AS 


		SELECT 
			c.Project
			,[Key]
			,[Summary]
			  ,[Status]
			  ,[Created]
			  ,[Updated]
			  ,[ResolutionDate]
			  ,[Epic]
			  ,[IssueFree]
			  ,[DeployEnv]
			  ,[Planned]
			  ,[Reporter]
			  ,[Assignee]
							FROM [ApplicationServices].[dbo].[tblJIRACustomerMapping] c
							JOIN (SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_Daily
								) deploy
								 ON deploy.Project = c.JIRAProject  
								AND deploy.Status IN (   'In Progress')
GO
