USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdateLateSource]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspUpdateLateSource]

AS

--EXEC applicationservices.dbo.uspUpdateLateSource

--late runs cause
SELECT *
into #LateRuns
FROM APPLICATIONSERVICES.DBO.vwAllJiraIssueTickets as a 
WHERE RunLate='Late'  AND TypeofIssue='Production Run'

--drop table #ShyftIssues
SELECT *
into #ShyftIssues
FROM APPLICATIONSERVICES.DBO.vwAllJiraIssueTickets as a 
WHERE TypeofIssue='Production Issue'-- and Source='Shyft'

--drop table #lateshyft
SELECT L.[Key],l.project,L.Created,sum(case when s.source='Shyft' then 1 else 0 end) as ShyftIssue,sum(case when s.Source<>'Shyft' then 1 else 0 end) as NonShyftIssue
into #lateshyft
FROM #ShyftIssues AS S
	right JOIN #LateRuns AS L ON S.Project=L.Project AND S.Created=L.Created
group by L.[Key],L.Created,L.Project

--SELECT *,CASE WHEN NonShyftIssue=0 and ShyftIssue>=1 THEN 'Shyft' ELSE 'Customer' END Shyftissues FROM #lateshyft

UPDATE APPLICATIONSERVICES_IM.dbo.AllProdRunTickets_FULL
SET [Source]='Customer'

UPDATE APPLICATIONSERVICES_IM.dbo.AllProdRunTickets_Daily
SET [Source]='Customer'

UPDATE J
SET [Source]=CASE WHEN NonShyftIssue=0 and ShyftIssue>=1 THEN 'Shyft' ELSE 'Customer' END
--SELECT *
FROM APPLICATIONSERVICES_IM.dbo.AllProdRunTickets_FULL AS J
	INNER JOIN #lateshyft AS L ON J.[Key]=L.[Key]

UPDATE J
SET [Source]=CASE WHEN NonShyftIssue=0 and ShyftIssue>=1 THEN 'Shyft' ELSE 'Customer' END
--SELECT *
FROM APPLICATIONSERVICES_IM.dbo.AllProdRunTickets_Daily AS J
	INNER JOIN #lateshyft AS L ON J.[Key]=L.[Key]


--SELECT CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end as Project,sum(CASE WHEN NonShyftIssue=0 and ShyftIssue>=1 THEN 1 ELSE 0 END) AS Shyftissues
--FROM #lateshyft as l
--	inner join [ApplicationServices_IM].[dbo].[ContractedHoursbyCustomerDynamic] AS C on ltrim(rtrim(l.Project))=ltrim(rtrim(C.mappingcustomer))
--GROUP BY CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end ,c.mappingcustomer
--order by CASE Project when 'Tesaro Expansion' THEN 'GSK' when 'Shire' then 'Takeda' when 'Blueprint Medicine' then 'Blueprint' else Project end
GO
