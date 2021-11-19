USE [TPS_DBA]
GO
IF OBJECT_ID('dbo.uspFindColumnOverflow') IS NOT NULL 
    BEGIN 
        DROP PROCEDURE dbo.uspFindColumnOverflow 
    END
GO
/****** Object:  StoredProcedure [dbo].[uspFindColumnOverflow]    Script Date: 10/9/2018 9:32:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspFindColumnOverflow]
/*******************************************************************************************
Name:               uspFindColumnOverflow
Purpose:            Find values exceeding column lengths
Inputs:             None
Author:             Aidan Fennessy
Created:            18th Sep 2018
History:            Date                Name                Comment
                    18th Sep 2018       Aidan Fennessy      Initial Creation

Copyright:
RunTime:            00:00:30 (HH:MM:SS)

Execution:            EXEC TPS_DBA.dbo.uspFindColumnOverflow '95000'
					  EXEC TPS_DBA.dbo.uspSendBadRecordsEmail     
					  --test on chargebacks file from insmed 20181211
					  --CAN be ran without providing a DataFeedID (in which case it will attempt to grab the DataFeedID associated with the most recent failed task in tblTaskQueue)

Output:				
					SELECT * FROM TPS_DBA.dbo.tblBadRecords
					SELECT * FROM TPS_DBA.DBO.TblBadData

*******************************************************************************************/
(	@DataFeedID VARCHAR(100) = NULL	)
AS
BEGIN
	SET NOCOUNT ON 

	BEGIN TRY

	--	DECLARE @DataFeedID VARCHAR(100) = NULL

	--1. Declare processing and IM DBs
	DECLARE @DBname varchar(100) = (SELECT TOP 1 TPS_DBA.dbo.udfGetArgument(Arguments, 'PROCESSINGDB') FROM [TPS_DBA].[dbo].[vwTaskQueue] WHERE statusid = 3 AND ErrorMessage <> 'A Task in parallel grouping has failed.  This task will not be executed and is being marked as Failed' order by convert(datetime, starttime) desc)
	DECLARE @IMDBname varchar(100) = (SELECT TOP 1 TPS_DBA.dbo.udfGetArgument(Arguments, 'IMDB') FROM [TPS_DBA].[dbo].[vwTaskQueue])

	--Grab RunID, DataFeedID, and ScenarioID for error finding
	DROP TABLE IF EXISTS #RunAndScenID; 
	select * into #RunAndScenID from 
	(select top (1) TPSScenarioTypeID, RunId, DataFeedID from [TPS_DBA].[dbo].[vwTaskQueue] 
	 where ErrorMessage like '%The value violates the MaxLength limit of this column%'
	 order by convert(datetime, starttime) desc) as TaskIDs

	--Datafeed IDs for errors
	DROP TABLE IF EXISTS #datafeedID; 
	select * into #datafeedID from 
	(SELECT * FROM [TPS_DBA].[dbo].[vwTaskQueue] 
	 where runid = (select RunId from #RunAndScenID)
	 and ErrorMessage is not null and datafeedID <> '') as dfID		

	--If DataFeedID is not supplied, use the most recent DataFeedID that failed due to a MaxLength limit.
	DECLARE @FailedDataFeedID varchar(MAX) = isnull(@DataFeedID, (select top 1 DataFeedID from #RunAndScenID))

	--Grab column characteristics from the problematic table
	DECLARE @FindIMtblSQL VARCHAR(MAX) = 'SELECT PARSENAME(ImportTableName, 1) AS BadIMTable FROM ' + @DBname + '.agd.tblMdDataFeed WHERE TPSDataFeedID = ' + @FailedDataFeedID + ''

	DROP TABLE IF EXISTS #BadIMTable; 
	CREATE TABLE #BadIMTable (BadIMTable nvarchar(100))
	Insert into #BadIMTable (BadIMTable)
	EXEC (@findIMtblSQL)
	DECLARE @BadIMTable varchar(100) = (select top 1 * from #BadIMTable)

	DECLARE @CreateColumnCharacteristicsTable VARCHAR(MAX) = ''
	SET @CreateColumnCharacteristicsTable = 
	'
	Use ' + @IMDBNAME + '
	IF OBJECT_ID(''TPS_DBA.dbo.tblTempColumnCharacteristics'', ''U'') IS NOT NULL
    DROP TABLE TPS_DBA.dbo.tblTempColumnCharacteristics; 

	CREATE TABLE TPS_DBA.dbo.tblTempColumnCharacteristics ([TABLE_QUALIFIER] nvarchar(100),	[TABLE_OWNER] nvarchar(100),	[TABLE_NAME] nvarchar(100),	[COLUMN_NAME] nvarchar(100),	[DATA_TYPE] nvarchar(100),	[TYPE_NAME] nvarchar(100),	[PRECISION] nvarchar(100),	[LENGTH] nvarchar(100),	[SCALE] nvarchar(100),	[RADIX] nvarchar(100),	[NULLABLE] nvarchar(100),	[REMARKS] nvarchar(100),	[COLUMN_DEF] nvarchar(100),	[SQL_DATA_TYPE] nvarchar(100),	[SQL_DATETIME_SUB] nvarchar(100),	[CHAR_OCTET_LENGTH] nvarchar(100),	[ORDINAL_POSITION] nvarchar(100),	[IS_NULLABLE] nvarchar(100),	[SS_DATA_TYPE] nvarchar(100)
)
	INSERT INTO TPS_DBA.dbo.tblTempColumnCharacteristics ([TABLE_QUALIFIER],	[TABLE_OWNER],	[TABLE_NAME],	[COLUMN_NAME],	[DATA_TYPE],	[TYPE_NAME],	[PRECISION],	[LENGTH],	[SCALE],	[RADIX],	[NULLABLE],	[REMARKS],	[COLUMN_DEF],	[SQL_DATA_TYPE],	[SQL_DATETIME_SUB],	[CHAR_OCTET_LENGTH],	[ORDINAL_POSITION],	[IS_NULLABLE],	[SS_DATA_TYPE])
	exec sp_columns @table_name = ' + @BadIMTable + '
	,@table_qualifier =  ' + @IMDBNAME + '
	
	'
	--Print @CreateColumnCharacteristicsTable
	Exec (@CreateColumnCharacteristicsTable)
	--SELECT * FROM TPS_DBA.dbo.tblTempColumnCharacteristics

	--Create duplicate table with NVARCHAR(max) columns 
	DECLARE @CreatetblBadDataTable NVARCHAR(MAX) =
	'IF OBJECT_ID(''[' + @IMDBNAME + '].[dbo].[tblBadData]'', ''U'') IS NOT NULL
		DROP TABLE [' + @IMDBNAME + '].[dbo].[tblBadData]; 
	 USE [' + @IMDBNAME + '] 
	 SET ANSI_NULLS ON
	 SET QUOTED_IDENTIFIER ON
		CREATE TABLE [' + @IMDBNAME + '].[dbo].[tblBadData](
		ID int IDENTITY(1,1),
		RedundantColumn [nvarchar](MAX) NULL)'	
	--PRINT @CreatetblBadDataTable
	EXEC (@CreatetblBadDataTable)

	DECLARE @script nvarchar(max) = ''
	SELECT @script = @script + 'ALTER TABLE ' + @IMDBNAME + '.dbo.tblBadData ADD [' + Column_Name + '] nvarchar(max); ' from TPS_DBA.dbo.tblTempColumnCharacteristics
	EXEC (@Script)

	DECLARE @ModifytblBadDataTable NVARCHAR(MAX) = 'ALTER TABLE ' + @IMDBNAME + '.dbo.tblBadData DROP COLUMN RedundantColumn; ALTER TABLE ' + @IMDBNAME + '.dbo.tblBadData DROP COLUMN ID;'
	EXEC (@ModifytblBadDataTable)

	--Update the "Load and Find overflowing data" scenario to bring in the relevant data 
	--Insert tblMdScenarioType Import scenario
	DECLARE @sqlscenarioinsert nvarchar(max) = 
	'
	IF NOT EXISTS ( SELECT 1 FROM ' + @DBname + '.AGD.tblMdScenarioType WHERE TPSScenarioTypeId = 1000000 AND ScenarioTypeDescription LIKE ''Load and Find overflowing data'')
	BEGIN
		SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMdScenarioType ON
		INSERT INTO ' + @DBname + '.AGD.tblMdScenarioType 
		(TPSScenarioTypeId,	ScenarioType,	ScenarioTypeDescription)
		Values (1000000, ''Load and Find overflowing data'', ''Load and Find overflowing data'')
		SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMdScenarioType OFF
	END
	'
	EXEC (@sqlscenarioinsert)

	--Update tblMdDataFeed Scenario	
	DECLARE @sql2 nvarchar(max) = 
	'
	UPDATE df
	SET ChildFileMask  = df.ChildFileMask,
		IsZipFile  = df.IsZipFile,
		DataFeedLocation  = df.DataFeedLocation,
		StartLine  = df.StartLine,
		DataFeedTypeId  = df.DataFeedTypeId,
		Delimiter  = df.Delimiter,
		MaxColumns  = df.MaxColumns,
		WorkSheets  = df.WorkSheets,
		TaskType  = df.TaskType,
		FileDate  = df.FileDate,
		BulkInsertRowTerminator  = df.BulkInsertRowTerminator,
		SourceId  = df.SourceId,
	FROM ' + @DBname + '.AGD.tblMdDataFeed df	
	WHERE df.TPSScenarioTypeId = 1000000 AND  df.DataFeedName = ''Load and Find overflowing data''
	'
	EXEC (@sql2)

	--Use uspExecuteTask manager to import the bad file
	DECLARE @importscript nvarchar(max) = 
	'
		USE ' + @DBNAME + '
		EXEC AGD.uspdatarun 1000000 '
	EXEC (@importscript)

	--Create len function arguments for each column		
	DROP TABLE IF EXISTS #tempColumnCharacteristicsLen; 
	CREATE TABLE #tempColumnCharacteristicsLen (ID int Identity(1,1), TABLE_OWNER nvarchar(100),	COLUMN_NAME nvarchar(100),	TYPE_NAME nvarchar(100),	PRECISION nvarchar(100),	NULLABLE nvarchar(100),	LenFunction nvarchar(100))
	insert into #tempColumnCharacteristicsLen
	select TABLE_OWNER, COLUMN_NAME, TYPE_NAME, PRECISION, NULLABLE,  '(DATALENGTH([' + COLUMN_NAME + '])/2)>' + PRECISION AS LenFunction from TPS_DBA.dbo.tblTempColumnCharacteristics 

	--Dynamic script to only return columns and records of those columns that are being overflowed
	DECLARE @script6 nvarchar(max) = ''
	SELECT @script6 = @script6 + ' IF EXISTS(select [' + Column_Name + '] from ' + @IMDBNAME + '.dbo.tblBadData where '+ LenFunction + ') BEGIN select ''' + Column_Name + ''' AS ColumnName, [' + Column_Name + '] AS BadRecord, MAX((DATALENGTH([' + COLUMN_NAME + '])/2)) as maxLen, ''' + PRECISION + ''' AS MaxAllowedLength from ' + @IMDBNAME + '.dbo.tblBadData where '+ LenFunction + ' GROUP BY [' + Column_Name + '] ORDER BY maxLen DESC END; '
	from #tempColumnCharacteristicsLen 
	--print @script6
	--EXEC (@script6)

	--Insert overflowing values into export table
	DROP TABLE IF EXISTS TPS_DBA.dbo.tblBadRecords; 
	CREATE TABLE TPS_DBA.dbo.tblBadRecords (FieldName nvarchar(max), Value nvarchar(max), LengthOfValue nvarchar(10), MaxAllowedLength nvarchar(10))
	Insert into TPS_DBA.dbo.tblBadRecords (FieldName, Value, LengthOfValue, MaxAllowedLength)
	EXEC (@script6)

	--RETURN RESULTS DATA TO EXECUTING USER
	--BAD VALUE
	SELECT * FROM TPS_DBA.dbo.tblBadRecords
	--AFFECTED COLUMN(S)
	SELECT TABLE_QUALIFIER, TABLE_OWNER, TABLE_NAME, CONCAT(TABLE_QUALIFIER,'.',TABLE_OWNER,'.',TABLE_NAME) AS 'Fully Qualified Object Name', COLUMN_NAME, [TYPE_NAME], [PRECISION], [LENGTH], IS_NULLABLE FROM TPS_DBA.dbo.tblTempColumnCharacteristics WHERE [COLUMN_NAME] IN (Select FieldName FROM TPS_DBA.dbo.tblBadRecords) -- ('mobile')
	--SUGGESTED ALTER SCRIPT
	DECLARE @AlterScript VARCHAR(MAX) = ''
	SELECT @AlterScript = @AlterScript + 'ALTER TABLE ' + CONCAT(cc.TABLE_QUALIFIER,'.',cc.TABLE_OWNER,'.',cc.TABLE_NAME) + ' ALTER COLUMN [' + COLUMN_NAME + '] ' + [TYPE_NAME] + '('+ TRY_CAST(ROUND((10 + MAX(br.LengthOfValue)), -1) AS varchar) +') '  
	FROM TPS_DBA.dbo.tblTempColumnCharacteristics cc
	JOIN TPS_DBA.dbo.tblBadRecords br ON br.FieldName = cc.COLUMN_NAME
	WHERE cc.COLUMN_NAME in (Select FieldName FROM TPS_DBA.dbo.tblBadRecords) -- ('mobile')
	GROUP BY TABLE_QUALIFIER, TABLE_OWNER, TABLE_NAME, COLUMN_NAME, [TYPE_NAME]
	SELECT @AlterScript AS 'Suggested Alter Script'


	-- SELECT * FROM TPS_DBA.DBO.TblBadData
	--Export the bad records
	DECLARE @timestamp varchar(100) = format(getdate(),'yyyyMMddHHmm')
	DECLARE @sql7 nvarchar(max) = 'UPDATE ' + @DBname + '.AGD.tblMdDataFeed SET DataFeedLocation = ''[ExtractLocation]\[Environment]\[DataDate]\BadRecords_' + @timestamp + '.xlsx'' WHERE TPSScenarioTypeId = 1000001 AND ImportTableName LIKE ''SELECT * FROM TPS_DBA.dbo.tblBadRecords'''
	EXEC (@sql7)

	--Use uspExecuteTask manager to export that table 
	DECLARE @exportscript nvarchar(max) 
	SET @exportscript = 
	'
		USE ' + @DBNAME + '
		EXEC AGD.uspdatarun 1000001
	'
	--PRINT @exportscript
	EXEC (@exportscript)
	

	RETURN

	END TRY


	BEGIN CATCH
		
		DECLARE @ErrorMessage VARCHAR(MAX) = 'There was an error in executing uspFindColumnOverflow. ' 
                 + 'Error Message: '+ ERROR_MESSAGE()
		+        + ' Line:' + CONVERT(VARCHAR,ERROR_LINE())
		+        + ' Error#:' + CONVERT(VARCHAR,ERROR_NUMBER())
		+        + ' Severity:' + CONVERT(VARCHAR,ERROR_SEVERITY())
		+        + ' State:' + CONVERT(VARCHAR,ERROR_STATE())
		+        + ' user:' + SUSER_NAME()
		+        + ' in proc:' + ISNULL(ERROR_PROCEDURE(),'N/A')
		+     + CASE WHEN OBJECT_NAME(@@PROCID) <> ERROR_PROCEDURE() THEN '<--' + OBJECT_NAME(@@PROCID) ELSE '' END   -- will display error from sub stored procedures
	     
		 RAISERROR(@ErrorMessage,16,1)
		 		  
	END CATCH

END



GO


