USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspGenerateChangeControlDetailsWithDateStatic]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspGenerateChangeControlDetailsWithDateStatic]

AS

--EXEC uspGenerateChangeControlDetailsWithDateStatic

/*
select * from ChangeControlDataSetPreviousMth
select * from ChangeControlDataSetCurrentMth
select * from ChangeControlDataSetPreviousQtr
select * from ChangeControlDataSetCurrentQtr
*/

SET NOCOUNT ON

DECLARE @StartDateMth DATE
DECLARE @EndDateMth DATE
DECLARE @StartDateMthPrev DATE
DECLARE @EndDateMthPrev DATE
DECLARE @Today DATE
DECLARE @StartDateWk DATE
DECLARE @EndDateWk DATE
DECLARE @PrevMth DATE
DECLARE @CURRQTR VARCHAR(10)
DECLARE @CURRQTRStart DATE
DECLARE @CURRQTREnd DATE
DECLARE @PrevQTREnd DATE
DECLARE @PREVQTR VARCHAR(10)
DECLARE @PREVQTRSTART DATE

set @StartDateMth=convert(varchar(2),MONTH(getdate()))+'/1/'+convert(varchar(4),YEAR(GETDATE()))
set @EndDateMth=DATEADD(dd,-1,(DATEADD(mm,1,@StartDateMth)))
set @Today=GETDATE()
set @StartDateWk=(select dateadd(dd,2,DATEADD(dd,-7,WeekEndingDateValue)) from [ApplicationServices].[AGD].[tblDate] where DateValue=@Today)
set @EndDateWk=(select dateadd(dd,1,WeekEndingDateValue) from [ApplicationServices].[AGD].[tblDate] where DateValue=@Today)
set @PrevMth=DATEADD(MM,-1,(Getdate()))
SET @StartDateMthPrev=convert(varchar(2),MONTH(@PrevMth))+'/1/'+convert(varchar(4),YEAR(@PrevMth))
SET @EndDateMthPrev=DATEADD(dd,-1,@startDatemth)

SET @CURRQTR=(select QuarterId from [ApplicationServices].[AGD].[tblDate] where DateValue = convert(varchar(10),GETDATE(),112))
SET @CURRQTRStart=(SELECT MIN(DateValue) FROM [ApplicationServices].[AGD].[tblDate] where QuarterID=@CURRQTR)
SET @CURRQTREnd=(SELECT MAX(DateValue) FROM [ApplicationServices].[AGD].[tblDate] where QuarterID=@CURRQTR)
set @PrevQTREnd= dateadd(dd,-1,@CURRQTRStart)
SET @PREVQTR=(SELECT QUARTERID FROM [ApplicationServices].[AGD].[tblDate] where DateValue=@PrevQTREnd)
SET @PREVQTRSTART = (SELECT MIN(DATEVALUE) FROM [ApplicationServices].[AGD].[tblDate] where QUARTERID=@PREVQTR)


-----------------------current month
TRUNCATE TABLE dbo.ChangeControlDataSetCurrentMth
INSERT INTO dbo.ChangeControlDataSetCurrentMth
SELECT *,@StartDateMth,@EndDateMth
FROM [ApplicationServices].[dbo].[vwAllJiraIssueTickets]
WHERE TypeofIssue='Story' and ((status <> 'Done' and convert(date,Created)<=@EndDateMth) OR (LEFT(CASE WHEN ResolutionDate='[empty]' THEN '2099-01-01' ELSE ResolutionDate END,10) BETWEEN @StartDateMth and @EndDateMth AND Status ='Done'))

TRUNCATE TABLE dbo.ChangeControlDataSetCurrentMthStaged
INSERT INTO dbo.ChangeControlDataSetCurrentMthStaged
SELECT f.*,
CASE WHEN CONVERT(date,created) <@StartDateMth THEN 1 ELSE 0 end AS CCStart,
CASE WHEN Status='DONE' AND LEFT(CASE WHEN ResolutionDate='[empty]' THEN '2099-01-01' ELSE ResolutionDate END,10) BETWEEN @StartDateMth AND @EndDateMth THEN 1 ELSE 0 END AS CCCompleted,
CASE WHEN CONVERT(date,created) between @StartDateMth and @EndDateMth THEN 1 ELSE 0 END AS CCAdded,
CASE WHEN Status <> 'Done' THEN 1 ELSE 0 END as CCEnd
FROM dbo.ChangeControlDataSetCurrentMth as f
	INNER JOIN [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C ON F.Project=C.MAPPINGCUSTOMER
ORDER BY f.Project,Created

---------------------------------Previous Month
TRUNCATE TABLE dbo.ChangeControlDataSetPreviousMth
INSERT INTO dbo.ChangeControlDataSetPreviousMth
SELECT *,@StartDateMthPrev,@EndDateMthPrev
FROM [ApplicationServices].[dbo].[vwAllJiraIssueTickets]
WHERE TypeofIssue='Story' and ((status <> 'Done' and convert(date,Created)<=@EndDateMthPrev) OR (LEFT(CASE WHEN ResolutionDate='[empty]' THEN '2099-01-01' ELSE ResolutionDate END,10) BETWEEN @StartDateMthPrev and @EndDateMthPrev AND Status ='Done'))

TRUNCATE TABLE dbo.ChangeControlDataSetPreviousMthStaged
INSERT INTO dbo.ChangeControlDataSetPreviousMthStaged
SELECT f.*,
CASE WHEN CONVERT(date,created) <@StartDateMthPrev THEN 1 ELSE 0 end AS CCStart,
CASE WHEN Status='DONE' AND LEFT(CASE WHEN ResolutionDate='[empty]' THEN '2099-01-01' ELSE ResolutionDate END,10) BETWEEN @StartDateMthPrev AND @EndDateMthPrev THEN 1 ELSE 0 END AS CCCompleted,
CASE WHEN CONVERT(date,created) between @StartDateMthPrev and @EndDateMthPrev THEN 1 ELSE 0 END AS CCAdded,
CASE WHEN Status <> 'Done' THEN 1 ELSE 0 END as CCEnd
FROM dbo.ChangeControlDataSetPreviousMth as f
	INNER JOIN [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C ON F.Project=C.MAPPINGCUSTOMER
ORDER BY f.Project,Created

------------------current qtr
TRUNCATE TABLE dbo.ChangeControlDataSetCurrentQtr
INSERT INTO dbo.ChangeControlDataSetCurrentQtr
SELECT *,@CURRQTRStart,@CURRQTREnd
FROM [ApplicationServices].[dbo].[vwAllJiraIssueTickets]
WHERE TypeofIssue='Story' and ((status <> 'Done' and convert(date,Created)<=@CURRQTREnd) OR (LEFT(CASE WHEN ResolutionDate='[empty]' THEN '2099-01-01' ELSE ResolutionDate END,10) BETWEEN @CURRQTRStart and @CURRQTREnd AND Status ='Done'))

TRUNCATE TABLE dbo.ChangeControlDataSetCurrentQtrStaged
INSERT INTO dbo.ChangeControlDataSetCurrentQtrStaged
SELECT f.*,
CASE WHEN CONVERT(date,created) <@CURRQTRStart THEN 1 ELSE 0 end AS CCStart,
CASE WHEN Status='DONE' AND LEFT(CASE WHEN ResolutionDate='[empty]' THEN '2099-01-01' ELSE ResolutionDate END,10) BETWEEN @CURRQTRStart AND @CURRQTREnd THEN 1 ELSE 0 END AS CCCompleted,
CASE WHEN CONVERT(date,created) between @CURRQTRStart and @CURRQTREnd THEN 1 ELSE 0 END AS CCAdded,
CASE WHEN Status <> 'Done' THEN 1 ELSE 0 END as CCEnd
FROM dbo.ChangeControlDataSetCurrentQtr as f
	INNER JOIN [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C ON F.Project=C.MAPPINGCUSTOMER
ORDER BY f.Project,Created

---------------previous qtr
TRUNCATE TABLE dbo.ChangeControlDataSetPreviousQtr
INSERT INTO dbo.ChangeControlDataSetPreviousQtr
SELECT *,@PREVQTRSTART,@PrevQTREnd
FROM [ApplicationServices].[dbo].[vwAllJiraIssueTickets]
WHERE TypeofIssue='Story' and ((status <> 'Done' and convert(date,Created)<=@PrevQTREnd) OR (LEFT(CASE WHEN ResolutionDate='[empty]' THEN '2099-01-01' ELSE ResolutionDate END,10) BETWEEN @PREVQTRSTART and @PrevQTREnd AND Status ='Done'))

TRUNCATE TABLE dbo.ChangeControlDataSetPreviousQtrStaged
INSERT INTO dbo.ChangeControlDataSetPreviousQtrStaged
SELECT f.*,
CASE WHEN CONVERT(date,created) <@PREVQTRSTART THEN 1 ELSE 0 end AS CCStart,
CASE WHEN Status='DONE' AND LEFT(CASE WHEN ResolutionDate='[empty]' THEN '2099-01-01' ELSE ResolutionDate END,10) BETWEEN @PREVQTRSTART AND @PrevQTREnd THEN 1 ELSE 0 END AS CCCompleted,
CASE WHEN CONVERT(date,created) between @PREVQTRSTART and @PrevQTREnd THEN 1 ELSE 0 END AS CCAdded,
CASE WHEN Status <> 'Done' THEN 1 ELSE 0 END as CCEnd
FROM dbo.ChangeControlDataSetPreviousQtr as f
	INNER JOIN [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C ON F.Project=C.MAPPINGCUSTOMER
ORDER BY f.Project,Created
GO
