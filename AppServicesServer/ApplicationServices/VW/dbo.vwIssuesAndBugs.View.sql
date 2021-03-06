USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwIssuesAndBugs]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[vwIssuesAndBugs]

as

SELECT Project,[Key] as [Ticket #],TypeofIssue as [Type],cast([Created] AS DATE) as [Report Date],Summary,case when LEFT(IssuePriority,1)='[' then null else LEFT(IssuePriority,1) end as Severity,Client_Facing as [Client Facing],[Source] as [Issue Source],case when ResolutionDate='[empty]' then '2099-01-01' else LEFT(ResolutionDate,10) END as [Resolve Date],ProdIssueRootCause as [Root Cause]
FROM [ApplicationServices_IM].[dbo].[AllProdIssueTickets_Full]
UNION
SELECT Project,[Key] as [Ticket #],TypeofIssue as [Type],cast([Created] AS DATE) as [Report Date],Summary,case when LEFT(IssuePriority,1)='[' then null else LEFT(IssuePriority,1) end as Severity,Client_Facing as [Client Facing],[Source] as [Issue Source],case when ResolutionDate='[empty]' then '2099-01-01' else LEFT(ResolutionDate,10) END as [Resolve Date],ProdIssueRootCause as [Root Cause]
FROM [ApplicationServices_IM].[dbo].[AllProdIssueTickets_Daily]
UNION
SELECT Project,[Key] as [Ticket #],IssueType as [Type],cast([Created] AS DATE) as [Report Date],Summary,case when left(priority,1) ='[' then null else LEFT(Priority,1) end as Severity,Client_Facing as [Client Facing],'Shyft' as [Issue Source],case when ResolutionDate='[empty]' then '2099-01-01' else LEFT(ResolutionDate,10) END as [Resolve Date],RootCause as [Root Cause]
FROM [ApplicationServices_IM].[dbo].[AllProdBugTickets_FULL]
UNION
SELECT Project,[Key] as [Ticket #],IssueType as [Type],cast([Created] AS DATE) as [Report Date],Summary,case when left(priority,1) ='[' then null else LEFT(Priority,1) end as Severity,Client_Facing as [Client Facing],'Shyft' as [Issue Source],case when ResolutionDate='[empty]' then '2099-01-01' else LEFT(ResolutionDate,10) END as [Resolve Date],RootCause as [Root Cause]
FROM [ApplicationServices_IM].[dbo].[AllProdBugTickets_Daily]

--select * from applicationservices.dbo.vwIssuesAndBugs

GO
