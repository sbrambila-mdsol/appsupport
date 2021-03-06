USE [ApplicationServices_IM]
GO
/****** Object:  View [dbo].[vwOpenRunTickets]    Script Date: 4/13/2020 3:16:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[vwOpenRunTickets]

as

SELECT 'Runs' as Typetix,assignee,[key],summary,project,Updated,Created,Status
FROM [ApplicationServices_IM].[dbo].[AllProdRunTickets_FULL]
where status <> 'done'
and assignee not in ('maraujo','srajan','hsouthworth','rsaika')

UNION

--ps open
SELECT 'Runs' as Typetix,assignee,[key],summary,project,Updated,Created,Status
FROM [ApplicationServices_IM].[dbo].[AllProdRunTickets_FULL]
where status <> 'done'
and assignee in ('maraujo','srajan','hsouthworth','rsaika')

GO
