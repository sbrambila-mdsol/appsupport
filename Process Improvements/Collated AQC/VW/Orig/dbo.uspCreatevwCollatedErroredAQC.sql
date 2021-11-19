USE [tps_dba]
GO

--drop procedure if exists [dbo].[uspCreatevwCollatedErroredAQC]
--go

IF OBJECT_ID('dbo.uspCreatevwCollatedErroredAQC') IS NOT NULL 
    BEGIN 
        DROP PROCEDURE dbo.uspCreatevwCollatedErroredAQC 
    END

/****** Object:  StoredProcedure [dbo].[uspCreatevwCollatedErroredAQC]    Script Date: 7/15/2019 5:04:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspCreatevwCollatedErroredAQC]
/*******************************************************************************************
Name:               uspCreatevwCollatedErroredAQC
Purpose:            Creates a view that UNIONs results from all databases that have tblQAQuery.
Inputs:             None
Author:             Aidan Fennessy 
Created:            13th Jun 2019
History:            Date                Name                Comment
                    13th Jun 2019       Aidan Fennessy      Initial Creation

Copyright:
RunTime:            00:00:00 (HH:MM:SS)

Execution:          EXEC TPS_DBA.dbo.uspCreatevwCollatedErroredAQC

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
	
 
	IF OBJECT_ID('tempdb.dbo.##DrDBs', 'U') IS NOT NULL
		DROP TABLE #DrDBs; 
	--DROP TABLE IF EXISTS #QADBs
	CREATE TABLE #DrDBs
	(
	ID INT IDENTITY (1,1),
	name VARCHAR (500),
	HasDrResults INT
	)
	
	INSERT INTO #DrDBs ([name], HasDrResults) 
	SELECT [name], HasDrResults = 0 FROM sys.databases where name not like 'report%'
	
	SET @DBname = (SELECT [name] FROM #DrDBs WHERE ID = 1)
	
	WHILE (@count <= (SELECT MAX(ID) FROM #DrDBs))
	BEGIN
		SET @sql = 
		'
		IF (
				SELECT count(*) FROM ' + @DBname + '.dbo.sysobjects 
				WHERE name = ''tblMdDataRunLog''
				AND NOT EXISTS 
				(	
					SELECT 1 FROM [' + @ClientName + '].sys.columns AS c 
				    WHERE [object_id] = OBJECT_ID(N''' + @ClientName + '.agd.'' + QUOTENAME(''tblMdDataRunLog''))
				    AND NOT EXISTS
				    (
				      SELECT 1 FROM [' + @DBname + '].sys.columns
				      WHERE [object_id] = OBJECT_ID(N''' + @DBname + '.agd.'' + QUOTENAME(''tblMdDataRunLog''))
				      AND name = c.name
				    )
				)
		   ) > 0
			BEGIN 
					UPDATE #DrDBs 
					SET HasDrResults = 1 
					WHERE name = ''' + @DBname + '''
			END
		'
		--PRINT @SQL
		EXEC (@sql)
		SET @count = @count + 1
		SET @DBname = (
					   SELECT [name] FROM #DrDBs 
					   WHERE ID = @count
					  )
	END
	
	DELETE FROM #DrDBs WHERE HasDrResults != 1
	DELETE FROM #DrDBs WHERE name like 'dbrestore%'
	
	SELECT * FROM #DrDBs

	DECLARE cursor1 CURSOR FOR 
	    select [name]
	    from #DrDBs

	OPEN cursor1
	
	FETCH NEXT FROM cursor1 INTO @DatabaseName
	

	WHILE @@FETCH_STATUS = 0
	BEGIN
	    -- Add the select code.
	    Set @DynSQL = @DynSQL + '
    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE ''''ClientName'''') AS Customer, ''''' + @DatabaseName + ''''' AS ''''Database'''', TPSScenarioTypeId, SUBSTRING(ErrorMessage, 41, LEN(ErrorMessage) - 40) as FailedAQCQueryIDs, InsertDate
	FROM (SELECT * FROM ( SELECT DENSE_RANK() over (partition by TPSScenarioTypeId order by InsertDate desc) as row_num, * 
        from ' + @DatabaseName + '.agd.tblMdDataRunLog WHERE ExecProcess like ''''AGD.uspQAGenerate%'''' AND (ErrorMessage IS NULL OR ErrorMessage LIKE ''''QA query error encountered in QueryId%'''')  ) AS Queries WHERE row_num = 1) qryC
	WHERE TRY_CAST(InsertDate AS date) >= TRY_CAST(DATEADD(month, -3, GETDATE()) AS date)
	AND ERRORMESSAGE IS NOT NULL
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
	
	IF OBJECT_ID('dbo.vwCollatedErroredAQC') IS NOT NULL 
    BEGIN 
        DROP VIEW dbo.vwCollatedErroredAQC 
    END

	--DROP VIEW IF EXISTS [dbo].[vwCollatedErroredAQC]

	SET @CreateView = 
	'	
	USE TPS_DBA;
	
	EXEC (''
	CREATE VIEW [dbo].[vwCollatedErroredAQC]

	AS

	' + @DynSQL + '
	'')
	'
	--PRINT @DynSQL
	--PRINT @CreateView
	EXEC (@CreateView)

END

GO


