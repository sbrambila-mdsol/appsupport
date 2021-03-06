USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwFFHoursALL]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE VIEW [dbo].[vwFFHoursALL]

AS

WITH starthours
AS (
    SELECT cast(d.DateValue AS DATE) AS TblDate
        ,h.StartDate
        ,H.EndDate
		,C.CustomerName as Client
        ,ProjectProjectName
        ,CASE when ReferenceNumber is null THEN h.Milestone else ReferenceNumber END as ReferenceNumber
        --,MileStone
        ,convert(float,SaturdayHours) as SaturdayHours
        ,convert(float,SundayHours) as SundayHours
        ,convert(float,MondayHours) as MondayHours
        ,convert(float,TuesdayHours) as TuesdayHours
        ,convert(float,WednesdayHours) as WednesdayHours
        ,convert(float,ThursdayHours) as ThursdayHours
        ,convert(float,FridayHours) as FridayHours
        ,left(Resource,charindex(' ',Resource,1)) as FirstName
        ,right(Resource,len(resource)-charindex(' ',Resource,1)) as LastName
		,m.GroupCode
    FROM ApplicationServices_IM.dbo.tbldfFFHours H
    LEFT JOIN [ApplicationServices].[AGD].[tblDate] D
        ON d.DateValue BETWEEN cast(h.startdate AS DATE)
                AND cast(h.enddate AS DATE)
	LEFT JOIN [ApplicationServices].dbo.Customer_XRef as C ON H.ProjectProjectName=C.Project
	LEFT JOIN ApplicationServices.dbo.tblFFGroupMapping AS M ON CASE when h.ReferenceNumber is null THEN h.Milestone else h.ReferenceNumber END=M.MILESTONE
     )
SELECT TblDate as [Date]
	,Client
    ,ProjectProjectName as Project
    ,ReferenceNumber as Task
    --,Milestone
    ,FirstName
    ,LastName
	,GroupCode
    ,CASE 
        WHEN Datename(dw, TblDate) = 'Saturday'
            THEN SaturdayHours
        WHEN Datename(dw, TblDate) = 'Sunday'
            THEN SundayHours
        WHEN Datename(dw, TblDate) = 'Monday'
            THEN MondayHours
        WHEN Datename(dw, TblDate) = 'Tuesday'
            THEN TuesdayHours
        WHEN Datename(dw, TblDate) = 'Wednesday'
            THEN WednesdayHours
        WHEN Datename(dw, TblDate) = 'Thursday'
            THEN ThursdayHours
        WHEN Datename(dw, TblDate) = 'Friday'
            THEN FridayHours end
        AS Hours
FROM starthours
GO
