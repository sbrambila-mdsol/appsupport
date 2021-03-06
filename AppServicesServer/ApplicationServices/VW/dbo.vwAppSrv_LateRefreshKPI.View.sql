USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_LateRefreshKPI]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vwAppSrv_LateRefreshKPI] AS 

SELECT LateRefreshKPI =   SUM([c7dRefreshes]) - SUM([c7dLateRefreshes])  
      ,Threshold = SUM([c7dRefreshes])
  FROM [ApplicationServices].[dbo].[vwAppSrv_JIRASummary]
 
GO
