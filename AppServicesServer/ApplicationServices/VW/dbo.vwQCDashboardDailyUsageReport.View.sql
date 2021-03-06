USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwQCDashboardDailyUsageReport]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 

CREATE VIEW [dbo].[vwQCDashboardDailyUsageReport] AS 


WITH ALLDATA
AS (
	 SELECT 
			dateused
			, reportname
			, username
			, DATEPART(dw, Dateused) as weekdaynumber
			, DATENAME(dw, Dateused) as weekday
			, start_of_week = dateadd(week, datediff(week, 0, Dateused), -1)
		FROM [vwQCDashboardDailyUsagePivoted]
 )
SELECT 
	Week_Beginning = cAST( selectedweeks.start_of_week AS DATE)
	,selectedweeks.reportname
	,[Sunday] = ISNULL(allSunday.username , '')
	,[Monday] = ISNULL(allMonday.username , '')
	,[Tuesday] = ISNULL(allTuesday.username , '')
	,[Wednesday] = ISNULL(allWednesday.username  ,'')
	,[Thursday] = ISNULL(allThursday.username , '')
	,[Friday] = ISNULL(allFriday.username , '')
	,[Saturday] = ISNULL(allSaturday.username , '')
FROM (SELECT DISTINCT
			 reportname
			 , start_of_week = dateadd(week, datediff(week, 0, Dateused), -1)
		FROM [vwQCDashboardDailyUsagePivoted] WHERE Dateused >= DATEADD(mm, -1, GETDATE()) ) selectedweeks
LEFT JOIN ALLDATA allSunday  ON selectedweeks.start_of_week = allSunday.start_of_week
							AND selectedweeks.reportname = allSunday.reportname
							AND allSunday.weekdaynumber = 1
LEFT JOIN ALLDATA allMonday  ON selectedweeks.start_of_week = allMonday.start_of_week
							AND selectedweeks.reportname = allMonday.reportname
							AND allMonday.weekdaynumber = 2
LEFT JOIN ALLDATA allTuesday  ON selectedweeks.start_of_week = allTuesday.start_of_week
							AND selectedweeks.reportname = allTuesday.reportname
							AND allTuesday.weekdaynumber = 3
LEFT JOIN ALLDATA allWednesday  ON selectedweeks.start_of_week = allWednesday.start_of_week
							AND selectedweeks.reportname = allWednesday.reportname
							AND allWednesday.weekdaynumber = 4
LEFT JOIN ALLDATA allThursday  ON selectedweeks.start_of_week = allThursday.start_of_week
							AND selectedweeks.reportname = allThursday.reportname
							AND allThursday.weekdaynumber = 5
LEFT JOIN ALLDATA allFriday  ON selectedweeks.start_of_week = allFriday.start_of_week
							AND selectedweeks.reportname = allFriday.reportname
							AND allFriday.weekdaynumber = 6
LEFT JOIN ALLDATA allSaturday  ON selectedweeks.start_of_week = allSaturday.start_of_week
							AND selectedweeks.reportname = allSaturday.reportname
							AND allSaturday.weekdaynumber = 7 

GO
