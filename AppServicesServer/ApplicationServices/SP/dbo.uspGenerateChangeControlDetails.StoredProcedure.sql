USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspGenerateChangeControlDetails]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspGenerateChangeControlDetails] (@StartDate VARCHAR(12), @EndDate VARCHAR(12))

AS

--EXEC dbo.uspGenerateChangeControlDetails '3/1/20','3/31/20'

SET @StartDate = convert(varchar(10),CONVERT(date,@startdate),120)
SET @EndDate = convert(varchar(10),CONVERT(date,@EndDate),120)

TRUNCATE TABLE dbo.ChangeControlDataSet
INSERT INTO dbo.ChangeControlDataSet
SELECT *
FROM [ApplicationServices].[dbo].[vwAllJiraIssueTickets]
WHERE TypeofIssue='Story' and ((status <> 'Done' and convert(date,Created)<=@EndDate) OR (LEFT(CASE WHEN ResolutionDate='[empty]' THEN '2099-01-01' ELSE ResolutionDate END,10) BETWEEN @startdate and @enddate AND Status ='Done'))

--SELECT CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end as Project,
--	SUM(CASE WHEN CONVERT(date,created) <@StartDate THEN 1 ELSE 0 end) as CCStart,
--	SUM(CASE WHEN Status='DONE' AND LEFT(CASE WHEN ResolutionDate='[empty]' THEN '2099-01-01' ELSE ResolutionDate END,10) BETWEEN @StartDate AND @EndDate THEN 1 ELSE 0 END) AS CCCompleted,
--	SUM(CASE WHEN CONVERT(date,created) between @StartDate and @EndDate THEN 1 ELSE 0 END) AS CCAdded,
--	sum(CASE WHEN Status <> 'Done' THEN 1 ELSE 0 END) as CCEnd
--FROM #CC as f
--	INNER JOIN [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C ON F.Project=C.MAPPINGCUSTOMER
--GROUP BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end
--ORDER BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end


SELECT f.*,CASE WHEN CONVERT(date,created) <@StartDate THEN 1 ELSE 0 end AS CCStart,
CASE WHEN Status='DONE' AND LEFT(CASE WHEN ResolutionDate='[empty]' THEN '2099-01-01' ELSE ResolutionDate END,10) BETWEEN @StartDate AND @EndDate THEN 1 ELSE 0 END AS CCCompleted,
CASE WHEN CONVERT(date,created) between @StartDate and @EndDate THEN 1 ELSE 0 END AS CCAdded,
CASE WHEN Status <> 'Done' THEN 1 ELSE 0 END as CCEnd
FROM dbo.ChangeControlDataSet as f
	INNER JOIN [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C ON F.Project=C.MAPPINGCUSTOMER
ORDER BY f.Project,Created

GO
