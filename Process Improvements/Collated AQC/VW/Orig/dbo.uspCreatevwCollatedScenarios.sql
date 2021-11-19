USE [tps_dba]
GO

--drop procedure if exists [dbo].[uspCreatevwCollatedScenarios]
--go

IF OBJECT_ID('dbo.uspCreatevwCollatedScenarios') IS NOT NULL 
    BEGIN 
        DROP PROCEDURE dbo.uspCreatevwCollatedScenarios 
    END

/****** Object:  StoredProcedure [dbo].[uspCreatevwCollatedQAResults]    Script Date: 7/15/2019 5:04:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspCreatevwCollatedScenarios]
/*******************************************************************************************
Name:               uspCreatevwCollatedScenarios
Purpose:            Creates a view that UNIONs results from all databases that have tblQAQuery.
Inputs:             None
Author:             Aidan Fennessy 
Created:            13th Jun 2019
History:            Date                Name                Comment
                    13th Jun 2019       Aidan Fennessy      Initial Creation

Copyright:
RunTime:            00:00:00 (HH:MM:SS)

Execution:          EXEC TPS_DBA.dbo.uspCreatevwCollatedScenarios

NOTES:				This procedure will only UNION results from a database if the columns for
					tblQAQuery in that database match the columns of those in the main processing
					database for the customer (which is presumed to be the client name, e.g. Greenwich).

					percent change compared to avg over lookup period plus standard deviation over lookup period. 

					
*******************************************************************************************/

AS
BEGIN
	SET NOCOUNT ON 

	DECLARE @sql nvarchar(max),
	@CreateView nvarchar(max),
	@ClientName nvarchar(max) = CASE WHEN @@SERVERNAME = 'PROARI27DB1' THEN 'ARIAD_PROCESSING_EU_Daily' WHEN @@SERVERNAME = 'PROTSR10DB1' THEN 'TESARO_CONTROLLER' WHEN @@SERVERNAME = 'PROAGN05DB5' THEN 'AGN_MEDICAL' WHEN @@SERVERNAME = 'PRDSHP10DB2' THEN 'RR_Processing' ELSE dbo.udfGetServerSetting('ClientName') END,
	@DBname VARCHAR(500),
	@count int = 1,
	@DatabaseName nvarchar(400),
	@DynSQL nvarchar(MAX) = ''
	
 
	IF OBJECT_ID('tempdb.dbo.##QADBs', 'U') IS NOT NULL
		DROP TABLE #QADBs; 
	--DROP TABLE IF EXISTS #QADBs
	CREATE TABLE #QADBs
	(
	ID INT IDENTITY (1,1),
	name VARCHAR (500),
	HasQAresults INT
	)
	
	INSERT INTO #QADBs ([name], HasQAResults) 
	SELECT [name], HasQAResults = 0 FROM sys.databases where name not like 'report%'
	
	SET @DBname = (SELECT [name] FROM #QADBs WHERE ID = 1)
	
	WHILE (@count <= (SELECT MAX(ID) FROM #QADBs))
	BEGIN
		SET @sql = 
		'
		IF (
				SELECT count(*) FROM ' + @DBname + '.dbo.sysobjects 
				WHERE name = ''tblMdScenarioType''
				AND NOT EXISTS 
				(	
					SELECT 1 FROM [' + @ClientName + '].sys.columns AS c 
				    WHERE [object_id] = OBJECT_ID(N''' + @ClientName + '.agd.'' + QUOTENAME(''tblMdScenarioType''))
				    AND NOT EXISTS
				    (
				      SELECT 1 FROM [' + @DBname + '].sys.columns
				      WHERE [object_id] = OBJECT_ID(N''' + @DBname + '.agd.'' + QUOTENAME(''tblMdScenarioType''))
				      AND name = c.name
				    )
				)
		   ) > 0
			BEGIN 
					UPDATE #QADBs 
					SET HasQAResults = 1 
					WHERE name = ''' + @DBname + '''
			END
		'
		--PRINT @SQL
		EXEC (@sql)
		SET @count = @count + 1
		SET @DBname = (
					   SELECT [name] FROM #QADBs 
					   WHERE ID = @count
					  )
	END
	
	DELETE FROM #QADBs WHERE HasQAResults != 1
	DELETE FROM #QADBs WHERE name like 'dbrestore%'
	--DELETE FROM #QADBs WHERE name like 'ULTRAGENYX'
	
	SELECT * FROM #QADBs

	DECLARE cursor1 CURSOR FOR 
	    select [name]
	    from #QADBs

	OPEN cursor1
	
	FETCH NEXT FROM cursor1 INTO @DatabaseName
	

	WHILE @@FETCH_STATUS = 0
	BEGIN
	    -- Add the select code.
	    Set @DynSQL = @DynSQL + '
    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE ''''ClientName'''') AS Customer, ''''' + @DatabaseName + ''''' AS ''''Database''''	
				,TPSScenarioTypeId	
				,ScenarioType	
				,ScenarioTypeDescription					
		FROM	' + @DatabaseName + '.agd.tblMdScenarioType
		' + CHAR(10) + ''

	    FETCH NEXT FROM cursor1
	    INTO @DatabaseName

	    -- If the loop continues, add the UNION ALL statement.
	    If @@FETCH_STATUS = 0
	    BEGIN
	        Set @DynSQL = @DynSQL + '' + CHAR(10) + ' UNION ALL ' + CHAR(10) + CHAR(10) + ''
	    END
	
	END

	CLOSE cursor1
	DEALLOCATE cursor1
	
	--Print @DynSQL
	--exec sp_executesql @DynSQL
	
	IF OBJECT_ID('dbo.vwCollatedScenarios') IS NOT NULL 
    BEGIN 
        DROP VIEW dbo.vwCollatedScenarios 
    END

	--DROP VIEW IF EXISTS [dbo].[vwCollatedScenarios]

	SET @CreateView = 
	'	
	USE TPS_DBA;
	
	EXEC (''
	CREATE VIEW [dbo].[vwCollatedScenarios]

	AS

	' + @DynSQL + '
	'')
	'
	--PRINT @DynSQL
	--PRINT @CreateView
	EXEC (@CreateView)

END

GO


