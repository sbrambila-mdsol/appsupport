USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAllJiraIssueMetrics]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE VIEW [dbo].[vwAllJiraIssueMetrics]
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
WITH SevPivot
AS (
	SELECT ja.Project
		,cast(ja.created AS DATE) AS Created
		,ja.IssuePriority
		,count(ja.[Key]) AS IssueCount
	FROM [dbo].[vwAllJiraIssueTickets] ja
	GROUP BY ja.Project
		,cast(ja.created AS DATE)
		,ja.IssuePriority
	)
	,SevStg
AS (
	SELECT Project
		,Created
		,coalesce([Critical], 0) AS Critical
		,coalesce([High], 0) AS High
		,coalesce([Low], 0) AS Low
		,coalesce([Medium], 0) AS Medium
	FROM SevPivot
	pivot(sum(IssueCount) FOR IssuePriority IN (
				[Critical]
				,[High]
				,[Low]
				,[Medium]
				)) AS Priorities
	)
SELECT SevStg.*
	,coalesce(HoursSpent, 0) AS HoursSpent
FROM SevStg
LEFT JOIN (
	SELECT hrs.Project AS Project
		,cast(hrs.[date] AS DATE) AS RefDate
		,hrs.HoursSpent AS HoursSpent
	FROM [dbo].[vwAllHoursGroupedbyDate] hrs
	) HRSGroup ON HRSGroup.Project = SevStg.Project
	AND HrsGroup.RefDate = cast(SevStg.Created AS DATE)
GO
