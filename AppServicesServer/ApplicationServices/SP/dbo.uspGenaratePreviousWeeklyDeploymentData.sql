USE [ApplicationServices]
GO

/****** Object:  StoredProcedure [dbo].[uspGenaratePreviousWeeklyDeploymentData]    Script Date: 4/13/2020 5:33:01 PM ******/
DROP PROCEDURE [dbo].[uspGenaratePreviousWeeklyDeploymentData]
GO

/****** Object:  StoredProcedure [dbo].[uspGenaratePreviousWeeklyDeploymentData]    Script Date: 4/13/2020 5:33:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspGenaratePreviousWeeklyDeploymentData]

AS

--EXEC dbo.uspGenaratePreviousWeeklyDeploymentData

SET NOCOUNT ON

--DECLARE VARIABLES
DECLARE @StartDateMth DATE-- ='3/22/20'
DECLARE @EndDateMth DATE-- ='3/28/20'
DECLARE @PrevStartDateMth DATE-- ='3/22/20'
DECLARE @PrevEndDateMth DATE-- ='3/28/20'
DECLARE @Today DATE

--add deploy date

--SET VARIABLES
set @Today=GETDATE()
set @StartDateMth=(select dateadd(dd,2,DATEADD(dd,-7,WeekEndingDateValue)) from [ApplicationServices].[AGD].[tblDate] where DateValue=@Today)
set @EndDateMth=(select dateadd(dd,1,WeekEndingDateValue) from [ApplicationServices].[AGD].[tblDate] where DateValue=@Today)
set @PrevStartDateMth=(select dateadd(dd,-7,@StartDateMth))
set @PrevEndDateMth=(select dateadd(dd,-7,@EndDateMth))


TRUNCATE TABLE [dbo].[DeployPreviousWeeklyData] 
INSERT INTO dbo.DeployPreviousWeeklyData
SELECT *,@PrevStartDateMth AS StartDt,@PrevEndDateMth AS EndDt
FROM [ApplicationServices].[dbo].[vwAllJiraIssueTickets]
WHERE TypeofIssue='Deployment' and convert(date,case when UPDATEd ='[empty]' then '2099-01-01' else Updated end) between @PrevStartDateMth and @PrevEndDateMth--created originally

--INSERT INTO SUMMARY

TRUNCATE TABLE dbo.DeployPreviousWeeklyDataSummary
INSERT INTO dbo.DeployPreviousWeeklyDataSummary
select Project,COUNT(*) AS Total,
sum(case when Planned<> 'Planned' then 1 else 0 End) as UnPlanned,
sum(case when Planned= 'Planned' then 1 else 0 End) as Planned,
sum(case when DeployEnv='PRO/PRD' then 1 else 0 End) as PRD,
sum(case when DeployEnv='UAT' then 1 else 0 End) as UAT,
sum(case when RunLate='No' then 1 else 0 End) as Late,
sum(case when IssueFree='No' then 1 else 0 End) as Issues,
@PrevStartDateMth as StartDt,@PrevEndDateMth as EndDt
from dbo.DeployPreviousWeeklyData 
GROUP BY Project
order by Project
GO


