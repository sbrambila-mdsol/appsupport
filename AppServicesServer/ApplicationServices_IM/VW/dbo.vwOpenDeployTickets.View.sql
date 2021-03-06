USE [ApplicationServices_IM]
GO
/****** Object:  View [dbo].[vwOpenDeployTickets]    Script Date: 4/13/2020 3:16:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE view [dbo].[vwOpenDeployTickets]

as

SELECT 'Issues' as Typetix,assignee,[key],Summary,project,Updated,Created
FROM [ApplicationServices_IM].[dbo].[AllProdDeployTickets_FULL]
where status <> 'done' and (Project <> 'Customer Success Production' and Project <> 'Customer Success OnGoing Scrum')
and assignee not in ('srajan','hsouthworth','rsaika')

UNION

--ps open
SELECT 'Issues' as Typetix,assignee,[key],summary,project,Updated,Created
FROM [ApplicationServices_IM].[dbo].[AllProdDeployTickets_FULL]
where status <> 'done' and (Project <> 'Customer Success Production' and Project <> 'Customer Success OnGoing Scrum')
and assignee in ('srajan','hsouthworth','rsaika')

GO
