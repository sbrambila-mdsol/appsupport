USE [ApplicationServices_IM]
GO
/****** Object:  View [dbo].[vwOpenIssueTickets]    Script Date: 4/13/2020 3:16:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vwOpenIssueTickets]

as

SELECT 'Issues' as Typetix,assignee,[key],summary,project,Updated,Created
FROM [ApplicationServices_IM].[dbo].[AllProdIssueTickets_Full]
where status <> 'done'
and assignee not in ('maraujo','srajan','hsouthworth','rsaika')

UNION

--ps open
SELECT 'Issues' as Typetix,assignee,[key],summary,project,Updated,Created
FROM [ApplicationServices_IM].[dbo].[AllProdIssueTickets_Full]
where status <> 'done'
and assignee in ('maraujo','srajan','hsouthworth','rsaika')

GO
