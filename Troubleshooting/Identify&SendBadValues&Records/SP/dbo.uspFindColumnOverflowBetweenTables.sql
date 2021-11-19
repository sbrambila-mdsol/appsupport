USE [TPS_DBA]
GO
IF OBJECT_ID('dbo.uspFindColumnOverflowBetweenTables') IS NOT NULL 
    BEGIN 
        DROP PROCEDURE dbo.uspFindColumnOverflowBetweenTables
    END
GO
/****** Object:  StoredProcedure [dbo].[uspFindColumnOverflowBetweenTables]    Script Date: 10/9/2018 9:32:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspFindColumnOverflowBetweenTables]
/*******************************************************************************************
Name:               uspFindColumnOverflowBetweenTables
Purpose:            Find values in a source table exceeding the column lengths of a target table.
Inputs:             None
Author:             Aidan Fennessy
Created:            18th Sep 2018
History:            Date                Name                Comment
                    11th Feb 2019       Aidan Fennessy      Initial Creation

Copyright:
RunTime:            00:00:30 (HH:MM:SS)

Execution:            EXEC TPS_DBA.dbo.uspFindColumnOverflowBetweenTables @TargetTable = 'tblCln_Concur_ReportDetail',  @SourceTable = 'tblDf_Concur_ReportDetail_History', @TargetDBname = 'Insmed', @SourceDBname = 'Insmed'

					
*******************************************************************************************/
(	@TargetTable VARCHAR(100), @SourceTable varchar(100), @TargetDBname varchar(100), @SourceDBname varchar(100))
AS
BEGIN
SET NOCOUNT ON 

	--DECLARE @TargetDBname varchar(100) = (SELECT TOP 1 TPS_DBA.dbo.udfGetArgument(Arguments, 'PROCESSINGDB') FROM [TPS_DBA].[dbo].[vwTaskQueue])
	--DECLARE @SourceDBname varchar(100) = (SELECT TOP 1 TPS_DBA.dbo.udfGetArgument(Arguments, 'IMDB') FROM [TPS_DBA].[dbo].[vwTaskQueue])

	--DECLARE @TargetTable varchar(100) = 'tblCln_Concur_ReportDetail'   
	--DECLARE @SourceTable NVARCHAR(100) = 'tblDf_Concur_ReportDetail_History'

	DECLARE 
	@CreateColumnCharacteristicsTable VARCHAR(MAX) = ''
	set @CreateColumnCharacteristicsTable = 
	'
	Use ' + @TargetDBname + '
	IF OBJECT_ID(''TPS_DBA.dbo.tblTempColumnCharacteristics'', ''U'') IS NOT NULL
    DROP TABLE TPS_DBA.dbo.tblTempColumnCharacteristics; 

	CREATE TABLE TPS_DBA.dbo.tblTempColumnCharacteristics ([TABLE_QUALIFIER] nvarchar(100),	[TABLE_OWNER] nvarchar(100),	[TABLE_NAME] nvarchar(100),	[COLUMN_NAME] nvarchar(100),	[DATA_TYPE] nvarchar(100),	[TYPE_NAME] nvarchar(100),	[PRECISION] nvarchar(100),	[LENGTH] nvarchar(100),	[SCALE] nvarchar(100),	[RADIX] nvarchar(100),	[NULLABLE] nvarchar(100),	[REMARKS] nvarchar(100),	[COLUMN_DEF] nvarchar(100),	[SQL_DATA_TYPE] nvarchar(100),	[SQL_DATETIME_SUB] nvarchar(100),	[CHAR_OCTET_LENGTH] nvarchar(100),	[ORDINAL_POSITION] nvarchar(100),	[IS_NULLABLE] nvarchar(100),	[SS_DATA_TYPE] nvarchar(100)
)
	INSERT INTO TPS_DBA.dbo.tblTempColumnCharacteristics ([TABLE_QUALIFIER],	[TABLE_OWNER],	[TABLE_NAME],	[COLUMN_NAME],	[DATA_TYPE],	[TYPE_NAME],	[PRECISION],	[LENGTH],	[SCALE],	[RADIX],	[NULLABLE],	[REMARKS],	[COLUMN_DEF],	[SQL_DATA_TYPE],	[SQL_DATETIME_SUB],	[CHAR_OCTET_LENGTH],	[ORDINAL_POSITION],	[IS_NULLABLE],	[SS_DATA_TYPE])
	exec sp_columns @table_name = ' + @TargetTable + '
	,@table_qualifier =  ' + @TargetDBname + '
	
	'
	--Print @CreateColumnCharacteristicsTable
	Exec (@CreateColumnCharacteristicsTable)
	--SELECT * FROM TPS_DBA.dbo.tblTempColumnCharacteristics

	--Create len function arguments for each column		
	DROP TABLE IF EXISTS #tempColumnCharacteristicsLen; 
	CREATE TABLE #tempColumnCharacteristicsLen (ID int Identity(1,1), TABLE_OWNER nvarchar(100),	COLUMN_NAME nvarchar(100),	TYPE_NAME nvarchar(100),	PRECISION nvarchar(100),	NULLABLE nvarchar(100),	LenFunction nvarchar(100))
	insert into #tempColumnCharacteristicsLen
	select TABLE_OWNER, COLUMN_NAME, TYPE_NAME, PRECISION, NULLABLE,  '(DATALENGTH([' + COLUMN_NAME + '])/2)>' + PRECISION AS LenFunction from TPS_DBA.dbo.tblTempColumnCharacteristics 

	--Dynamic script to only return columns and records of those columns that are being overflowed
	DECLARE @script6 nvarchar(max) = ''
	SELECT @script6 = @script6 + ' IF EXISTS(select [' + Column_Name + '] from ' + @SourceDBname + '.dbo.' + @SourceTable + ' where '+ LenFunction + ') BEGIN select ''[' + Column_Name + ']'' AS ColumnName, [' + Column_Name + '] AS BadRecord, MAX((DATALENGTH([' + COLUMN_NAME + '])/2)) as maxLen, ''' + PRECISION + ''' AS MaxAllowedLength from ' + @SourceDBname + '.dbo.' + @SourceTable + ' where '+ LenFunction + ' GROUP BY [' + Column_Name + '] ORDER BY maxLen DESC END; '
	from #tempColumnCharacteristicsLen 
	--print @script6
	--EXEC (@script6)

	--Insert overflowing values into export table
	DROP TABLE IF EXISTS TPS_DBA.dbo.tblBadRecords; 
	CREATE TABLE TPS_DBA.dbo.tblBadRecords (FieldName nvarchar(max), Value nvarchar(max), LengthOfValue nvarchar(10), MaxAllowedLength nvarchar(10))
	Insert into TPS_DBA.dbo.tblBadRecords (FieldName, Value, LengthOfValue, MaxAllowedLength)
	EXEC (@script6)
	SELECT * FROM TPS_DBA.dbo.tblBadRecords
	SELECT * FROM TPS_DBA.dbo.tblTempColumnCharacteristics WHERE [COLUMN_NAME] in (Select FieldName FROM TPS_DBA.dbo.tblBadRecords)



RETURN

END

GO


