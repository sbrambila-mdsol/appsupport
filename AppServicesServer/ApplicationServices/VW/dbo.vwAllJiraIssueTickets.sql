USE [ApplicationServices]
GO

/****** Object:  View [dbo].[vwAllJiraIssueTickets]    Script Date: 4/15/2020 8:43:45 AM ******/
DROP VIEW [dbo].[vwAllJiraIssueTickets]
GO

/****** Object:  View [dbo].[vwAllJiraIssueTickets]    Script Date: 4/15/2020 8:43:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vwAllJiraIssueTickets]
/*******************************************************************************************
Purpose:	Provide a view for all JIRA Tickets
Inputs:
Author:				Sam Bloch
Created:			05/09/2019
Copyright:
Change History:
Execution: Select * FROM [dbo].[vwAllJiraIssueTickets]
*******************************************************************************************/
AS

/*
with allvals as (
SELECT [Key]
	,[Project]
	,[Summary]
	,[Status]
	,[Client_Facing]
	,[Identified_By]
	,[Source]
	,[ProdIssueRootCause]
	,[TypeofIssue]
	,[IssuePriority]
	,cast([Created] as date) as Created
	,[Updated]
	,[EscalatedtoTech]
	,[RunLate]
	,nullif([SLA],'[empty]') as SLA
	,[Assignee]
FROM [ApplicationServices_IM].dbo.[AllProdIssueTickets_Full] FULLSet
join [dbo].[tblMDClientProjectBridge] PB on PB.JiraProjectName=FULLSet.Project
UNION
SELECT [Key]
	,[Project]
	,[Summary]
	,[Status]
	,[Client_Facing]
	,[Identified_By]
	,[Source]
	,[ProdIssueRootCause]
	,[TypeofIssue]
	,[IssuePriority]
	,cast([Created] as date) as Created
	,[Updated]
	,[EscalatedtoTech]
	,[RunLate]
	,nullif([SLA],'[empty]') as SLA
	,[Assignee]
FROM [ApplicationServices_IM].dbo.[AllProdIssueTickets_Daily] Daily
join [dbo].[tblMDClientProjectBridge] PB on PB.JiraProjectName=Daily.Project
)
Select AllVals.*,1 AS 'IssueCount', DENSE_RANK() OVER (PARTITION BY Project,cast(created as date) order by cast(created as datetime)   ) as Rnk
from allvals

*/

WITH allvals
AS (
	SELECT [Key]
		,[Project]
		,[Summary]
		,[Status]
		,[Client_Facing]
		,[Identified_By]
		,[Source]
		,[ProdIssueRootCause]
		,[TypeofIssue]
		,[IssueDesc]
		,[IssuePriority]
		,cast([Created] AS DATE) AS Created
		,[Updated]
		,[EscalatedtoTech]
		,[RunLate]
		,nullif([SLA], '[empty]') AS SLA
		,[Assignee]
		,NULL AS IssueFree
		,case when ResolutionDate='[empty]' then '1/1/2099' else ResolutionDate END as ResolutionDate
		,NULL AS Epic
		,NULL AS HoursSpent
		,1 AS 'IssueCount'
		,case when IssuePriority='Critical' then 1 else 0 end as 'Critical Tickets'
		,case when IssuePriority='High' then 1 else 0 end as 'High Tickets'
		,case when IssuePriority='Medium' then 1 else 0 end as 'Medium Tickets'
		,case when IssuePriority='Low' then 1 else 0 end as 'Low Tickets'
		,NULL AS Planned
		,NULL AS DeployEnv
		,NULL AS Reporter
		,Vendor
		,HandledBy
	FROM [ApplicationServices_IM].dbo.[AllProdIssueTickets_Full] FULLSet
	INNER JOIN [dbo].[tblMDClientProjectBridge] PB
		ON PB.JiraProjectName = FULLSet.Project
	
	UNION
	
	SELECT [Key]
		,[Project]
		,[Summary]
		,[Status]
		,[Client_Facing]
		,[Identified_By]
		,[Source]
		,[ProdIssueRootCause]
		,[TypeofIssue]
		,[IssueDesc]
		,[IssuePriority]
		,cast([Created] AS DATE) AS Created
		,[Updated]
		,[EscalatedtoTech]
		,[RunLate]
		,nullif([SLA], '[empty]') AS SLA
		,[Assignee]
		,NULL AS IssueFree
		,case when ResolutionDate='[empty]' then '1/1/2099' else ResolutionDate END as ResolutionDate
		,NULL AS Epic
		,NULL AS HoursSpent
		,1 AS 'IssueCount'
		,case when IssuePriority='Critical' then 1 else 0 end as 'Critical Tickets'
		,case when IssuePriority='High' then 1 else 0 end as 'High Tickets'
		,case when IssuePriority='Medium' then 1 else 0 end as 'Medium Tickets'
		,case when IssuePriority='Low' then 1 else 0 end as 'Low Tickets'
		,NULL AS Planned
		,NULL AS DeployEnv
		,NULL AS Reporter
		,Vendor
		,HandledBy
	FROM [ApplicationServices_IM].dbo.[AllProdIssueTickets_Daily] Daily
	INNER JOIN [dbo].[tblMDClientProjectBridge] PB
		ON PB.JiraProjectName = Daily.Project

	UNION

	SELECT [Key]
		,[Project]
		,[Summary]
		,[Status]
		,NULL AS [Client_Facing]
		,NULL AS [Identified_By]
		,NULL AS [Source]
		,RootCause as  [ProdIssueRootCause]
		,'Deployment' AS [TypeofIssue]
		,NULL AS [IssueDesc]
		,NULL AS [IssuePriority]
		,cast([Created] AS DATE) AS Created
		,DeployDate as [Updated]--represents deploy date
		,NULL AS [EscalatedtoTech]
		,OnTime AS [RunLate]
		,NULL AS SLA
		,[Assignee]
		,IssueFree
		,case when ResolutionDate='[empty]' then '1/1/2099' else ResolutionDate END as ResolutionDate
		,Epic
		,NULL AS HoursSpent
		,1 AS 'IssueCount'
		,NULL as 'Critical Tickets'
		,NULL as 'High Tickets'
		,NULL as 'Medium Tickets'
		,NULL as 'Low Tickets'
		,Planned
		,DeployEnv
		,Reporter
		,NULL as Vendor
		,HandledBy
	FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_FULL FULLSet
	INNER JOIN [dbo].[tblMDClientProjectBridge] PB
		ON PB.JiraProjectName = FULLSet.Project

	UNION

	SELECT [Key]
		,[Project]
		,[Summary]
		,[Status]
		,NULL AS [Client_Facing]
		,NULL AS [Identified_By]
		,NULL AS [Source]
		,RootCause as  [ProdIssueRootCause]
		,'Deployment' AS [TypeofIssue]
		,NULL AS [IssueDesc]
		,NULL AS [IssuePriority]
		,cast([Created] AS DATE) AS Created
		,DeployDate as [Updated]
		,NULL AS [EscalatedtoTech]
		,OnTime AS [RunLate]
		,NULL AS SLA
		,[Assignee]
		,IssueFree
		,case when ResolutionDate='[empty]' then '1/1/2099' else ResolutionDate END as ResolutionDate
		,Epic
		,NULL AS HoursSpent
		,1 AS 'IssueCount'
		,NULL as 'Critical Tickets'
		,NULL as 'High Tickets'
		,NULL as 'Medium Tickets'
		,NULL as 'Low Tickets'
		,Planned
		,DeployEnv
		,Reporter
		,NULL as Vendor
		,HandledBy
	FROM [ApplicationServices_IM].dbo.AllProdDeployTickets_Daily FULLSet
	INNER JOIN [dbo].[tblMDClientProjectBridge] PB
		ON PB.JiraProjectName = FULLSet.Project

		UNION

---stories
SELECT [Key]
		,[Project]
		,[Summary]
		,[Status]
		,ClientFacing AS [Client_Facing]
		,IdentifiedBy AS [Identified_By]
		,NULL AS [Source]
		,NULL AS  [ProdIssueRootCause]
		,'Story' AS [TypeofIssue]
		,NULL AS [IssueDesc]
		,[Priority] AS [IssuePriority]
		,cast([Created] AS DATE) AS Created
		,[Updated]
		,NULL AS [EscalatedtoTech]
		,NULL AS [RunLate]
		,NULL AS SLA
		,[Assignee]
		,NULL AS IssueFree
		,case when ResolutionDate='[empty]' then '1/1/2099' else ResolutionDate END as ResolutionDate
		,NULL AS Epic
		,NULL AS HoursSpent
		,1 AS 'IssueCount'
		,NULL as 'Critical Tickets'
		,NULL as 'High Tickets'
		,NULL as 'Medium Tickets'
		,NULL as 'Low Tickets'
		,NULL AS Planned
		,NULL AS DeployEnv
		,Reporter
		,NULL as Vendor
		,NULL AS HandledBy
	FROM [ApplicationServices_IM].dbo.AllProdStoryTickets_FULL FULLSet
	INNER JOIN [dbo].[tblMDClientProjectBridge] PB
		ON PB.JiraProjectName = FULLSet.Project
	WHERE StoryType='Implementation/Change Control'

	UNION

	SELECT [Key]
		,[Project]
		,[Summary]
		,[Status]
		,ClientFacing AS [Client_Facing]
		,IdentifiedBy AS [Identified_By]
		,NULL AS [Source]
		,NULL AS  [ProdIssueRootCause]
		,'Story' AS [TypeofIssue]
		,NULL AS [IssueDesc]
		,[Priority] AS [IssuePriority]
		,cast([Created] AS DATE) AS Created
		,[Updated]
		,NULL AS [EscalatedtoTech]
		,NULL AS [RunLate]
		,NULL AS SLA
		,[Assignee]
		,NULL AS IssueFree
		,case when ResolutionDate='[empty]' then '1/1/2099' else ResolutionDate END as ResolutionDate
		,NULL AS Epic
		,NULL AS HoursSpent
		,1 AS 'IssueCount'
		,NULL as 'Critical Tickets'
		,NULL as 'High Tickets'
		,NULL as 'Medium Tickets'
		,NULL as 'Low Tickets'
		,NULL AS Planned
		,NULL AS DeployEnv
		,Reporter
		,NULL as Vendor
		,NULL AS HandledBy
	FROM [ApplicationServices_IM].dbo.AllProdStoryTickets_Daily FULLSet
	INNER JOIN [dbo].[tblMDClientProjectBridge] PB
		ON PB.JiraProjectName = FULLSet.Project
	WHERE StoryType='Implementation/Change Control'
-----

	UNION 

	SELECT [Key]
		,[Project]
		,[Summary]
		,[Status]
		,[Client_Facing]
		,IdentifiedBy AS [Identified_By]
		,'Shyft' AS [Source]
		,BugRootCause AS [ProdIssueRootCause]
		,'Bug' AS [TypeofIssue]
		,[IssueDesc]
		,[Priority] as [IssuePriority]
		,cast([Created] AS DATE) AS Created
		,[Updated]
		,NULL AS [EscalatedtoTech]
		,NULL AS [RunLate]
		,NULL AS SLA
		,[Assignee]
		,NULL as IssueFree
		,case when ResolutionDate='[empty]' then '1/1/2099' else ResolutionDate END as ResolutionDate
		,NULL as Epic
		,NULL AS HoursSpent
		,1 AS 'IssueCount'
		,NULL as 'Critical Tickets'
		,NULL as 'High Tickets'
		,NULL as 'Medium Tickets'
		,NULL as 'Low Tickets'
		,NULL as Planned
		,NULL as DeployEnv
		,Reporter
		,NULL as Vendor
		,NULL AS HandledBy
	FROM [ApplicationServices_IM].dbo.AllProdBugTickets_FULL FULLSet
	INNER JOIN [dbo].[tblMDClientProjectBridge] PB
		ON PB.JiraProjectName = FULLSet.Project

	UNION

	SELECT [Key]
		,[Project]
		,[Summary]
		,[Status]
		,[Client_Facing]
		,IdentifiedBy AS [Identified_By]
		,'Shyft' AS [Source]
		,BugRootCause AS [ProdIssueRootCause]
		,'Bug' AS [TypeofIssue]
		,[IssueDesc]
		,[Priority] as [IssuePriority]
		,cast([Created] AS DATE) AS Created
		,[Updated]
		,NULL AS [EscalatedtoTech]
		,NULL AS [RunLate]
		,NULL AS SLA
		,[Assignee]
		,NULL as IssueFree
		,case when ResolutionDate='[empty]' then '1/1/2099' else ResolutionDate END as ResolutionDate
		,NULL as Epic
		,NULL AS HoursSpent
		,1 AS 'IssueCount'
		,NULL as 'Critical Tickets'
		,NULL as 'High Tickets'
		,NULL as 'Medium Tickets'
		,NULL as 'Low Tickets'
		,NULL as Planned
		,NULL as DeployEnv
		,Reporter
		,NULL as Vendor
		,NULL AS HandledBy
	FROM [ApplicationServices_IM].dbo.AllProdBugTickets_Daily FULLSet
	INNER JOIN [dbo].[tblMDClientProjectBridge] PB
		ON PB.JiraProjectName = FULLSet.Project
	
	UNION
	
	SELECT [Key]
		,[Project]
		,[Summary]
		,[Status]
		,NULL AS [Identified_By]
		,NULL AS [Identified_By]
		,[Source]
		,NULL AS ProdIssueRootCause
		,'Production Run' AS TypeofIssue
		,NULL AS [IssueDesc]
		,NULL AS IssuePriority
		,[Created]
		,[Updated]
		,NULL AS EscalatedtoTech
		,case when [OnTime]='Yes' then 'On Time' else 'Late' end  AS RunLate
		,NULL AS SLA
		,[Assignee]
		,case when [IssueFree] = 'Yes' then 'No Issues' else 'Has Issues' end as IssueFree
		,case when ResolutionDate='[empty]' then '1/1/2099' else ResolutionDate END as ResolutionDate
		,Em.Descr AS [Epic]
		,NULL AS HoursSpent
		,1 AS 'IssueCount'
		,null as 'Critical Tickets'
		,null as 'High Tickets'
		,null as 'Medium Tickets'
		,null as 'Low Tickets'
		,NULL AS Planned
		,NULL AS DeployEnv
		,NULL AS Reporter
		,NULL as Vendor
		,HandledBy
	FROM [ApplicationServices_IM].[dbo].[AllProdRunTickets_FULL] Runs
	LEFT JOIN [ApplicationServices].dbo.tblMDEpicsMap EM
		ON Em.Epic = Runs.Epic
	INNER JOIN [dbo].[tblMDClientProjectBridge] PB
		ON PB.JiraProjectName = Runs.Project
	
	UNION
	
	SELECT [Key]
		,[Project]
		,[Summary]
		,[Status]
		,NULL AS [Client_Facing]
		,NULL AS [Identified_By]
		,[Source]
		,NULL AS ProdIssueRootCause
		,'Production Run' AS TypeofIssue
		,NULL AS [IssueDesc]
		,NULL AS IssuePriority
		,[Created]
		,[Updated]
		,NULL AS EscalatedtoTech
		,case when [OnTime]='Yes' then 'On Time' else 'Late' end  AS RunLate
		,NULL AS SLA
		,[Assignee]
		,case when [IssueFree] = 'Yes' then 'No Issues' else 'Has Issues' end as IssueFree
		,case when ResolutionDate='[empty]' then '1/1/2099' else ResolutionDate END as ResolutionDate
		,Em.Descr AS [Epic]
		,NULL AS HoursSpent
		,1 AS 'IssueCount'
		,null as 'Critical Tickets'
		,null as 'High Tickets'
		,null as 'Medium Tickets'
		,null as 'Low Tickets'
		,NULL AS Planned
		,NULL AS DeployEnv
		,NULL AS Reporter
		,NULL as Vendor
		,HandledBy
	FROM [ApplicationServices_IM].[dbo].[AllProdRunTickets_Daily] RunsDaily
	LEFT JOIN [ApplicationServices].dbo.tblMDEpicsMap EM
		ON Em.Epic = RunsDaily.Epic
	INNER JOIN [dbo].[tblMDClientProjectBridge] PB
		ON PB.JiraProjectName = RunsDaily.Project

	UNION
	
	SELECT null AS [Key]
		,[Project]
		,NULL AS [Summary]
		,NULL AS [Status]
		,NULL AS [Client_Facing]
		,NULL AS [Identified_By]
		,NULL AS [Source]
		,NULL AS [ProdIssueRootCause]
		,'Hours Data' AS [TypeofIssue]
		,NULL AS [IssueDesc]
		,'OpenAir' AS [IssuePriority]
		,[Date] AS [Created]
		,NULL AS [Updated]
		,NULL AS [EscalatedtoTech]
		,NULL AS [RunLate]
		,NULL AS [SLA]
		,NULL AS [Assignee]
		,NULL AS IssueFree
		,NULL AS ResolutionDate
		,NULL AS Epic
		,HoursSpent AS HoursSpent
		,0 AS 'IssueCount'
		,null as 'Critical Tickets'
		,null as 'High Tickets'
		,null as 'Medium Tickets'
		,null as 'Low Tickets'
		,NULL AS Planned
		,NULL AS DeployEnv
		,NULL AS Reporter
		,NULL as Vendor
		,NULL AS HandledBy
	FROM [dbo].[vwAllHoursGroupedbyDate]
	where project is not null
	)
SELECT AllVals.*,cast(WeekEndingDateID as date) as WeekEndingDate

FROM allvals
join agd.tblDate d on cast(d.datedesc as date)=cast(allvals.Created as date)


GO


