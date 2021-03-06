USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspGenerateFrankReport]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspGenerateFrankReport] (@StartDate VARCHAR(12),@EndDate VARCHAR(12))

AS

--exec dbo.uspGenerateFrankReport '1/1/20','3/31/20'
SET NOCOUNT ON

DECLARE @YearMth VARCHAR(12)
SET @YearMth = CONVERT(VARCHAR(4),YEAR(@StartDate))+'_'+CONVERT(VARCHAR(2),MONTH(@StartDate))
--PRINT @YEARMTH


----------------FF Hours
SELECT client,GroupCode,SUM(HOURs) as HRs,convert(varchar(4),year(date))+'_'+convert(varchar(2),MONTH(date)) as YearMth
INTO #ALL
FROM [ApplicationServices].[dbo].[vwFFHoursALL]
GROUP BY Client,GroupCode,convert(varchar(4),year(date))+'_'+convert(varchar(2),MONTH(date))

SELECT CASE WHEN C.Customer='Greenwich US' then 'Greenwich' else C.Customer end as Customer,ISNULL(C.ContratedbySUBHRs,0) AS OpsPlanned,SUM(CASE WHEN GroupCode='SUB' THEN HRs ELSE 0 END) AS OpsActual,C.ContractedAMSHRs AS AMSPlanned,SUM(CASE WHEN GroupCode='AMS' THEN HRs ELSE 0 END) AS AMSActual,SUM(CASE WHEN GroupCode='NBL' THEN HRs ELSE 0 END) AS NonBillActual,SUM(CASE WHEN GroupCode='IMP' THEN HRs ELSE 0 END) AS IMPActual
FROM #ALL AS A
	INNER JOIN [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C ON case when a.client ='Tesaro' then 'Tesaro Expansion' when a.client = 'Blueprint' then 'Blueprint Medicine' else ltrim(rtrim(A.Client)) end=ltrim(rtrim(C.MappingCustomer))
WHERE YearMth=@YearMth
GROUP BY CASE WHEN C.Customer='Greenwich US' then 'Greenwich' else C.Customer end,C.ContractedAMSHRs,C.ContratedbySUBHRs
order by CASE WHEN C.Customer='Greenwich US' then 'Greenwich' else C.Customer end

---------check
--select SUM(hours) as hrs
--from [ApplicationServices].[dbo].[vwFFHoursALL]
--where GroupCode='ams' and Date between @StartDate and @EndDate and client='Adamas'

--------------runs
SELECT CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end as Project,COUNT([key]) as PlannedDeliverables,
	SUM(CASE WHEN RUNLATE='LATE' THEN 1 ELSE 0 END) AS LateDeliverables
FROM [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C
	LEFT JOIN APPLICATIONSERVICES.DBO.vwAllJiraIssueTickets as a ON LTRIM(RTRIM(C.MappingCustomer))= LTRIM(RTRIM(A.Project)) AND TypeofIssue='Production Run' 
WHERE convert(date,created) between @StartDate and @EndDate
GROUP BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end
ORDER BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end

--late runs cause
SELECT *
into #LateRuns
FROM APPLICATIONSERVICES.DBO.vwAllJiraIssueTickets as a 
WHERE convert(date,created) between @StartDate and @EndDate and RunLate='Late'  AND TypeofIssue='Production Run'

--drop table #ShyftIssues
SELECT *
into #ShyftIssues
FROM APPLICATIONSERVICES.DBO.vwAllJiraIssueTickets as a 
WHERE convert(date,created) between @StartDate and @EndDate AND TypeofIssue='Production Issue'-- and Source='Shyft'

--drop table #lateshyft
SELECT L.[Key],l.project,L.Created,sum(case when s.source='Shyft' then 1 else 0 end) as ShyftIssue,sum(case when s.Source<>'Shyft' then 1 else 0 end) as NonShyftIssue
into #lateshyft
FROM #ShyftIssues AS S
	right JOIN #LateRuns AS L ON S.Project=L.Project AND S.Created=L.Created
group by L.[Key],L.Created,L.Project

SELECT CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end as Project,sum(CASE WHEN NonShyftIssue=0 and ShyftIssue>=1 THEN 1 ELSE 0 END) AS Shyftissues
FROM #lateshyft as l
	inner join [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C on ltrim(rtrim(l.Project))=ltrim(rtrim(C.mappingcustomer))
GROUP BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end ,c.mappingcustomer
order by CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end

------------------issues
SELECT CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end as Project,
	sum(case when IssuePriority IN ('Critical','High') then 1 else 0 end) as CriticalIssues,
	sum(case when IssuePriority IN ('Critical','High') and client_facing ='Yes' then 1 else 0 end) as CriticalClientFacingIssues,
	sum(case when IssuePriority NOT IN ('Critical','High') then 1 else 0 end) as NonCriticalIssues,
	sum(case when IssuePriority NOT IN ('Critical','High') and client_facing ='Yes' then 1 else 0 end) as NonCriticalClientFacingIssues,
	sum(case when Source ='Shyft' then 1 else 0 end) as ShyftIssues,
	sum(case when Typeofissue='Bug' and client_facing ='No' then 1 else 0 end) as NonClientFacingBugs,
	SUM(case when issuepriority ='[empty]' then 1 else 0 end) as MissingPriority,
	SUM(case when source is null then 1 else 0 end) as MissingSource,
	COUNT(*) as TotalIssuesAndBugs
FROM [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C
	LEFT JOIN APPLICATIONSERVICES.DBO.vwAllJiraIssueTickets as a ON LTRIM(RTRIM(C.MappingCustomer))= LTRIM(RTRIM(A.Project)) AND TypeofIssue in ('Production Issue','Bug')
WHERE convert(date,created) between @StartDate and @EndDate
GROUP BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end
ORDER BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end

---------------stories

set @StartDate = convert(varchar(10),CONVERT(date,@startdate),120)
print @startdate

set @EndDate = convert(varchar(10),CONVERT(date,@EndDate),120)
print @Enddate

SELECT *
into #cc--select *
FROM APPLICATIONSERVICES_IM.DBO.AllProdStoryTickets_FULL AS F
	INNER JOIN [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C ON F.Project=C.MAPPINGCUSTOMER and StoryType='Implementation/Change Control'
WHERE (status <> 'Done' and convert(date,Created)<=@EndDate) or 
	(left(case when ResolutionDate='[empty]' then '2099-01-01' else ResolutionDate END,10) between @startdate and @enddate and Status ='Done')
and StoryType='Implementation/Change Control'

insert into #cc
SELECT *
FROM APPLICATIONSERVICES_IM.DBO.AllProdStoryTickets_Daily AS F
	INNER JOIN [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C ON F.Project=C.MAPPINGCUSTOMER and StoryType='Implementation/Change Control'
WHERE (status <> 'Done' and convert(date,Created)<=@EndDate) or --convert(date,Created) <='2/29/20'-- and 
--(convert(date,Updated) between @StartDate and @EndDate and Status ='Done')
(left(case when ResolutionDate='[empty]' then '2099-01-01' else ResolutionDate END,10) between @startdate and @enddate and Status ='Done')
and StoryType='Implementation/Change Control'

select * from #cc

SELECT CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end as Project,
	SUM(case when CONVERT(date,created) <@StartDate then 1 else 0 end) as CCStart,
	--SUM(CASE WHEN Status='DONE' AND CONVERT(DATE,Updated) BETWEEN @StartDate AND @EndDate THEN 1 ELSE 0 END) AS CCCompleted,
	SUM(CASE WHEN Status='DONE' AND left(case when ResolutionDate='[empty]' then '2099-01-01' else ResolutionDate END,10) BETWEEN @StartDate AND @EndDate THEN 1 ELSE 0 END) AS CCCompleted,
	SUM(case when CONVERT(date,created) between @StartDate and @EndDate THEN 1 ELSE 0 END) AS CCAdded,
	sum(case when status <> 'Done' then 1 else 0 end) as CCEnd
FROM #CC as f
	INNER JOIN [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C ON F.Project=C.MAPPINGCUSTOMER
GROUP BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end
ORDER BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end

--exec dbo.uspGenerateFrankReport '2/1/20','2/29/20'

--SELECT CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' else Project end as Project,
--	SUM(case when CONVERT(date,created) <='2/1/20' then 1 else 0 end) as CCStart,
--	SUM(CASE WHEN Status='DONE' AND CONVERT(DATE,Updated) BETWEEN '2/1/20' AND '2/29/20' THEN 1 ELSE 0 END) AS CCCompleted,
--	SUM(case when CONVERT(date,created) between '2/1/20' and '2/29/20' THEN 1 ELSE 0 END) AS CCAdded,
--	sum(case when status <> 'Done' then 1 else 0 end) as CCEnd
--FROM #CC as f
--	INNER JOIN [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C ON F.Project=C.MAPPINGCUSTOMER
--GROUP BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' else Project end
--ORDER BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' else Project end
GO
