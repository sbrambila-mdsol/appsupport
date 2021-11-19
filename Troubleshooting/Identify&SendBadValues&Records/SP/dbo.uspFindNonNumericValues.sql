USE [TPS_DBA]
GO
IF OBJECT_ID('dbo.uspFindNonNumericValues') IS NOT NULL 
    BEGIN 
        DROP PROCEDURE dbo.uspFindNonNumericValues
    END
GO
/****** Object:  StoredProcedure [dbo].[uspFindNonNumericValues]    Script Date: 10/9/2018 9:32:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspFindNonNumericValues]
/*******************************************************************************************
Name:               uspFindColumnMismatches
Purpose:            Find non numeric values in a source table where the target table column type is numeric.
Inputs:             None
Author:             Aidan Fennessy
Created:            18th Sep 2018
History:            Date                Name                Comment
                    11th Feb 2019       Aidan Fennessy      Initial Creation

Copyright:
RunTime:            00:00:30 (HH:MM:SS)

Execution:            EXEC TPS_DBA.dbo.uspFindNonNumericValues @TargetTable = 'tblCln_Concur_ReportDetail',  @SourceTable = 'tblDf_Concur_ReportDetail_History', @TargetDBname = 'Insmed', @SourceDBname = 'Insmed'
					 
					
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

	--only return columns and records of those columns that are not numeric
	DECLARE @script6 nvarchar(max) = ''
	SELECT @script6 = @script6 + ' IF EXISTS(select [' + Column_Name + '] from ' + @SourceDBname + '.dbo.' + @SourceTable + ' where isnumeric('+ Column_Name + ')<>1) BEGIN select ''[' + Column_Name + ']'' AS ColumnName, [' + Column_Name + '] AS BadRecord from ' + @SourceDBname + '.dbo.' + @SourceTable + ' where isnumeric('+ Column_Name + ')<>1 AND '+ Column_Name + ' IS NOT NULL GROUP BY [' + Column_Name + '] END; '
		from TPS_DBA.dbo.tblTempColumnCharacteristics 
		where [TYPE_NAME] like 'numeric'
	print @script6
	--EXEC (@script6)

	IF OBJECT_ID('TPS_DBA.dbo.tblBadRecords', 'U') IS NOT NULL
    DROP TABLE TPS_DBA.dbo.tblBadRecords; 

	CREATE TABLE TPS_DBA.dbo.tblBadRecords (FieldName nvarchar(max), Value nvarchar(max))
	Insert into TPS_DBA.dbo.tblBadRecords (FieldName, Value)
	EXEC (@script6)
	SELECT * FROM TPS_DBA.dbo.tblBadRecords
	-- SELECT * FROM TPS_DBA.DBO.TblBadData



RETURN

END

GO


