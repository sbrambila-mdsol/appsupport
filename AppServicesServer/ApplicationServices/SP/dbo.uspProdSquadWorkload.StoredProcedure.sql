USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspProdSquadWorkload]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspProdSquadWorkload]

AS

SET NOCOUNT ON


--Grab all the prod squad hours
SELECT K.TaskGroupID,K.TaskGroup,T.*
INTO #ProdSquadGrp--select *
FROM ApplicationServices_IM.dbo.tbldfOpenAirHours AS T
	INNER JOIN ApplicationServices_IM.dbo.Tasks  AS K ON T.TASK=K.Task
WHERE [LastName] IN ('Araujo','Rajan','Tran','Fennessy')

--select * from #ProdSquadGrp where taskgroupid is null

--get groups and group ids
SELECT TASKGROUP,TaskGroupID
into #groups
FROM ApplicationServices_IM.dbo.Tasks
WHERE PSFLAG='Y'
GROUP BY TaskGroup,TaskGroupID
ORDER BY TaskGroupID

--create staging by by customer by month
SELECT YearMth,CLIENT,TaskGroup,TaskGroupID,SUM(convert(real,HOURS)) AS HoursWrk
INTO #FinalStage
FROM #ProdSquadGrp
GROUP BY YearMth,CLIENT,TaskGroup,TaskGroupID
ORDER BY Client,YearMth DESC,TaskGroupID

--Get all customers and months
SELECT DISTINCT YearMth,Client
INTO #ALLRECS
FROM #FinalStage as f

--Figure out all combinations
SELECT *
INTO #FULL
FROM #ALLRECS
	inner join #groups as g on 3=3

--Find what is missing
select YearMth,Client,TaskGroup,TaskGroupID
into #missingdata 
from #full
except
select YearMth,Client,TaskGroup,TaskGroupID
from #FinalStage

--add in the missing with zero row hours
INSERT INTO #FinalStage
SELECT *,0 AS HrsWk
FROM #missingdata

--*************************final report
SELECT * FROM #FinalStage order by YearMth,Client,TaskGroupID
--*******************************

GO
