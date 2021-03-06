USE [ApplicationServices]
GO
/****** Object:  View [dbo].[vwAGDSplitWeek]    Script Date: 4/13/2020 3:12:41 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vwAGDSplitWeek]
/*******************************************************************************************
Purpose: Split Week table. Developer needs to reference correct split week table
Inputs:
Author: Kevin Lee
Created:  02.08.2014
Copyright:
Change History:	

*******************************************************************************************/
AS
	

	----------
	--If split week is needed then 
	--		1) Comment out the section named PlaceHolder 
	--		2) Uncomment out the section named SplitWeek.
	--		3) Replace [AGD_Framework_IM] with the correct database name and populate the tbldfIMSSplitWeek
	--Reason for the uncommenting and commenting out is that it will break the build when trying to script out since we maybe
	--referenceing a table that does not exists
	---------	

	-----------
	--PlaceHolder
	-----------
	SELECT NULL AS SplitWeekStartDate, NULL AS SplitWeekEndDate, NULL AS NoDays, NULL AS WeekEndingDateValue
		 , NULL AS WeekNoYYWW, NULL AS CalendarMonth, NULL AS MonthEndDate, NULL AS MonthNoYYMM 


	-----------
	--SplitWeek
	-----------
	--SELECT SplitWeekStartDate, SplitWeekEndDate, NoDays, WeekEndingDateValue, WeekNoYYWW, CalendarMonth, MonthEndDate, MonthNoYYMM 
	--FROM [AGD_Framework_IM].dbo.tbldfIMSSplitWeek 
GO
