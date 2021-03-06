USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[updateQAdashboardTables]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[updateQAdashboardTables]
/*******************************************************************************************
Purpose: Update QA tables used for the QA dashboard
Inputs:
Author:  Mike Araujo
Created: 8/14/2019
Copyright:
Change History:
Usage:
	EXEC [dbo].[updateQAdashboardTables]
*******************************************************************************************/

AS
BEGIN
------------------------------------Variable Declaration----------------------------------------------------------------

DROP TABLE IF EXISTS #QAtables

CREATE TABLE #QAtables
(
	ID INT IDENTITY (1,1),
	schemaName VARCHAR (500),
	tableName VARCHAR (500)
)

DECLARE @custQAtable VARCHAR (500) --Customer Specific QA Table ex. StrataLogs.TSR.vwCollatedQAResults, StrataLogs.TSR.vwCollatedQAErroredAQC, etc.
DECLARE @SQL VARCHAR (max)
DECLARE @Count INT = 1

--------------------------------------------BODY------------------------------------------------------------------------

--Set QATables
INSERT INTO #QAtables (schemaName, tableName)
SELECT [TABLE_SCHEMA], [TABLE_NAME]  FROM stratalogs.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'vwCollatedQAResults'


--Truncate QA_last10_all_servers, for each customer add new results to QA_all_servers 
TRUNCATE TABLE [applicationServices].[dbo].[QA_all_servers]

WHILE @count <= (SELECT MAX(ID) FROM #QAtables)
BEGIN
	SET @custQAtable = (SELECT schemaName FROM #QAtables WHERE ID = @Count) + '.' + (SELECT tableName FROM #QAtables WHERE ID = @Count)

	--INSERT new entries QA_all_servers
	SET @sql = 
	'INSERT INTO [applicationServices].[dbo].[QA_all_servers] ( [Customer], [Database], [QueryID], [QueryType], [QueryName], [AlertType], [WarnThreshold], [FailThreshold], [ExpectedResult], [CurrentDataDate], [CurrentResult], [PriorResult], [PriorDataDate], [PercentChange], [TPSQueryID], [TPSScenarioTypeId], [avg_results], [STD_DEV], [LOWER_BOUND], [UPPER_BOUND], [Query], [Failure], [Warning], [InsertDate] )
	SELECT [Customer], [Database], [QueryID], [QueryType], [QueryName], [AlertType], [WarnThreshold], [FailThreshold], [ExpectedResult], [CurrentDataDate], [CurrentResult], [PriorResult], [PriorDataDate], [PercentChange], [TPSQueryID], [TPSScenarioTypeId], [avg_results], [STD_DEV], [LOWER_BOUND], [UPPER_BOUND], [Query], [Failure], [Warning], [InsertDate]
    FROM StrataLogs.' + @custQAtable + ' a'
	EXEC (@sql)
	--PRINT @sql
	
	SET @count = @count + 1
END


--Reset Variables
TRUNCATE TABLE #QAtables
SET @Count = 1

--SET QATables
INSERT INTO #QAtables (schemaName, tableName)
SELECT [TABLE_SCHEMA], [TABLE_NAME]  FROM stratalogs.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'vwCollatedTopTenQAResults'

--Truncate QA_last10_all_servers, for each customer add new results to QA_last10_all_servers 
TRUNCATE TABLE [applicationServices].[dbo].[QA_last10_all_servers]

WHILE @count <= (SELECT MAX(ID) FROM #QAtables)
BEGIN
	SET @custQAtable = (SELECT schemaName FROM #QAtables WHERE ID = @Count) + '.' + (SELECT tableName FROM #QAtables WHERE ID = @Count)

    --INSERT new entries INTO QA_last10_all_servers
	SET @sql = 
	'INSERT INTO [applicationServices].[dbo].[QA_last10_all_servers] ( [Customer], [Database], [row_num], [TPSRunId], [QueryID], [TPSScenarioTypeId], [Result], [DataDate], [Query], [InsertDate], [ExpectedResult], [Failure], [Warning] )
	SELECT [Customer], [Database], [row_num], [TPSRunId], [QueryID], [TPSScenarioTypeId], [Result], [DataDate], [Query], [InsertDate], [ExpectedResult], [Failure], [Warning] FROM StrataLogs.' + @custQAtable + ' a'
	EXEC (@sql)
	--PRINT @sql
	
	SET @count = @count + 1
END


--Reset Variables
TRUNCATE TABLE #QAtables
SET @Count = 1

--Set QATables
INSERT INTO #QAtables (schemaName, tableName)
SELECT [TABLE_SCHEMA], [TABLE_NAME]  FROM stratalogs.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'vwCollatedErroredAQC'

--Truncate QA_last10_all_servers, for each customer add new results to QA_errors_all_servers
TRUNCATE TABLE [applicationServices].[dbo].[QA_errors_all_servers]

WHILE @count <= (SELECT MAX(ID) FROM #QAtables)
BEGIN
	SET @custQAtable = (SELECT schemaName FROM #QAtables WHERE ID = @Count) + '.' + (SELECT tableName FROM #QAtables WHERE ID = @Count)

	--Insert new errored queries
	SET @sql = 
	'INSERT INTO [applicationServices].[dbo].[QA_errors_all_servers] ( [Customer], [Database], [TPSScenarioTypeId], [FailedAQCQueryIDs], [InsertDate] )
	SELECT a.[Customer], a.[Database], a.[TPSScenarioTypeId], a.[FailedAQCQueryIDs], a.[InsertDate]
	FROM StrataLogs.' + @custQAtable + ' a'
	EXEC (@sql)
	--PRINT @sql

	SET @Count = @Count + 1
END


--Reset Variables
TRUNCATE TABLE #QAtables
SET @Count = 1

--Set QATables
INSERT INTO #QAtables (schemaName, tableName)
SELECT [TABLE_SCHEMA], [TABLE_NAME]  FROM stratalogs.INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'vwCollatedScenarios'

--Truncate QA_last10_all_servers, for each customer add new results to QA_scenario_all_servers
TRUNCATE TABLE [applicationServices].[dbo].[QA_scenario_all_servers]

WHILE @count <= (SELECT MAX(ID) FROM #QAtables)
BEGIN
	SET @custQAtable = (SELECT schemaName FROM #QAtables WHERE ID = @Count) + '.' + (SELECT tableName FROM #QAtables WHERE ID = @Count)
	
	--Insert new scenarios
	SET @sql = 
	'INSERT INTO [applicationServices].[dbo].[QA_scenario_all_servers] ([Customer], [Database], [TPSScenarioTypeId], [ScenarioType], [ScenarioTypeDescriptiON])
	SELECT a.[Customer], a.[Database], a.[TPSScenarioTypeId], a.[ScenarioType], a.[ScenarioTypeDescriptiON]
	FROM StrataLogs.' + @custQAtable + ' a'
	EXEC (@sql)
	--PRINT @sql

	SET @count = @count + 1
END
END
GO
