USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwQCDashboardDailyUsagePivoted]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE VIEW [dbo].[vwQCDashboardDailyUsagePivoted] AS 
SELECT distinct e.dateused,
  e.reportname,
  LEFT(r.username , LEN(r.username)-1) username
FROM [ApplicationServices].[dbo].[vwQCDashboardUsage]  e
CROSS APPLY
(
    SELECT r.username + ', '
    FROM [ApplicationServices].[dbo].[vwQCDashboardUsage]  r
    where e.dateused = r.dateused
      and e.reportname = r.reportname
    FOR XML PATH('')
) r (username)
   
GO
