USE [ApplicationServices_IM]
GO
/****** Object:  View [dbo].[vwIssueLast7Days]    Script Date: 4/13/2020 3:16:12 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vwIssueLast7Days]

as

SELECT *
FROM [ApplicationServices_IM].[dbo].[AllProdRunTickets_FULL]
where ontime ='no' and datediff(Day,convert(datetime,Created),getdate()) <=7 and created not like '%9/27/2019%'
union
SELECT *
FROM [ApplicationServices_IM].[dbo].[AllProdRunTickets_Daily]
where ontime ='no' and datediff(Day,convert(datetime,Created),getdate()) <=7 and Created not like '%9/27/2019%'
GO
