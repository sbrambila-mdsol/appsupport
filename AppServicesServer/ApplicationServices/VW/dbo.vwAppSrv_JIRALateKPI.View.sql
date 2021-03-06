USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAppSrv_JIRALateKPI]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 
CREATE VIEW [dbo].[vwAppSrv_JIRALateKPI] AS 

SELECT 
	 c7dSHYFTLateRefreshKPI = (SELECT COUNT(runs.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_Daily
							) runs
							WHERE    runs.OnTime = 'No'
							 
								AND CAST( Created  AS DATE)  >= CAST( DATEADD(dd, -7 ,GETDATE()) AS Date) 
							) 
	  ,p7dSHYFTLateRefreshKPI = (SELECT COUNT(runs.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_Daily
							) runs
							WHERE    runs.OnTime = 'No'
							 
								AND CAST( Created  AS DATE)  BETWEEN  CAST( DATEADD(dd, -15 ,GETDATE()) AS Date) 
													AND CAST( DATEADD(dd, -8 ,GETDATE()) AS Date) 
							) 
	 ,c7dNONSHYFTLateRefreshKPI = (SELECT COUNT(runs.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_Daily
							) runs
							WHERE    runs.OnTime = 'No'
							 
								AND CAST( Created  AS DATE)  >= CAST( DATEADD(dd, -7 ,GETDATE()) AS Date) 
							) 
	  ,p7dNONSHYFTLateRefreshKPI = (SELECT COUNT(runs.[Key])
							FROM (SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_FULL
										UNION
										SELECT * FROM [ApplicationServices_IM].dbo.AllProdRunTickets_Daily
							) runs
							WHERE    runs.OnTime = 'No'
							 
								AND CAST( Created  AS DATE)  BETWEEN  CAST( DATEADD(dd, -15 ,GETDATE()) AS Date) 
													AND CAST( DATEADD(dd, -8 ,GETDATE()) AS Date) 
							) 


							 
GO
