USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAllHoursGroupedbyDate]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE VIEW [dbo].[vwAllHoursGroupedbyDate]
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


SELECT JiraProjectName as Project,[Date],sum(cast(hours as decimal (12,4))) as HoursSpent
from ApplicationServices.dbo.tblFFFinalHours Hist
join [dbo].[tblMDClientProjectBridge] PB on PB.JiraProjectName=case when Hist.Client ='Tesaro' then 'Tesaro Expansion' else Hist.client end
where Task='Production - Issue Resolution'
group by JiraProjectName,[Date]
GO
