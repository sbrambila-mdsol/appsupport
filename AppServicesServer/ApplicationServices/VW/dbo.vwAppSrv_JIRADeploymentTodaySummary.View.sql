USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_JIRADeploymentTodaySummary]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












 

CREATE VIEW [dbo].[vwAppSrv_JIRADeploymentTodaySummary] AS 

	 SELECT  
		TodayScheduledDeployment = (SELECT COUNT(*) FROM [ApplicationServices].[dbo].[vwAppSrv_JIRADeploymentDetailList] WHERE  FilterValue = 'Today' )
		,TodayScheduledDeploymentCompleted = (SELECT COUNT(*) FROM [ApplicationServices].[dbo].[vwAppSrv_JIRADeploymentDetailList] WHERE  FilterValue = 'Today' AND [Status] <> 'To Do' )
		,BadDepolymentTicket7Day = (SELECT COUNT(*) FROM [ApplicationServices].[dbo].[vwAppSrv_JIRADeploymentDetailList] WHERE FilterValue = '7 Day Bad Ticket')
		,LateDepolymentTicket7Day = (SELECT COUNT(*) FROM [ApplicationServices].[dbo].[vwAppSrv_JIRADeploymentDetailList] WHERE FilterValue = '7 Day Late Ticket')

	--	,DeploymentRemaining = (SELECT COUNT(*) FROM [ApplicationServices].[dbo].[vwAppSrv_JIRADeploymentToday] WHERE [Status] <> 'Done')
	--	,DeploymentCompleted = COUNT(*) - (SELECT COUNT(*) FROM [ApplicationServices].[dbo].[vwAppSrv_JIRADeploymentToday] WHERE [Status] <> 'Done')
	--	,PlannedDeployment = (SELECT COUNT(*) FROM [ApplicationServices].[dbo].[vwAppSrv_JIRADeploymentToday] WHERE [Planned] = 'Planned' )
	--	,UnplannedSHYFTDeployment = (SELECT COUNT(*) FROM [ApplicationServices].[dbo].[vwAppSrv_JIRADeploymentToday] WHERE [Planned] = 'Unplanned - Shyft' )
	--	,UnplannedCustomerDeployment = (SELECT COUNT(*) FROM [ApplicationServices].[dbo].[vwAppSrv_JIRADeploymentToday] WHERE [Planned] = 'Unplanned - Customer' )
	--	,DeploymentCreatedToday = (SELECT COUNT(*) FROM [ApplicationServices].[dbo].[vwAppSrv_JIRADeploymentToday] WHERE CAST( Created AS date) = CAST(GETDATE() AS date)) 

								 

GO
