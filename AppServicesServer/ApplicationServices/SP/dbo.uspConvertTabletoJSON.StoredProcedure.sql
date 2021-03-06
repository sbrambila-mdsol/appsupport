USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspConvertTabletoJSON]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspConvertTabletoJSON]
/*******************************************************************************************
Purpose: convert a sql table into a new table capable to be exported as a JSON file
Inputs: name of table to be converted to JSON, name of JSON table
Author:  Mike Araujo
Created:
Copyright:
Change History:
Usage:
	EXEC [dbo].[convertTabletoJSON] 'dbo.ErrorResults', 'dbo.JSONtable'
*******************************************************************************************/
(    
	@SourceTable NVARCHAR(MAX),
	@JSONtable NVARCHAR(MAX)
 )
AS
BEGIN
DROP TABLE IF EXISTS ##Columns
DROP TABLE IF EXISTS ##SourceTable

DECLARE @sql nvarchar(max)
DECLARE @columnName varchar(max)
DECLARE @columnList varchar(max) = ''

SET @sql = 'DROP TABLE IF EXISTS ' + @JSONtable

EXEC (@sql)

SET @sql = 
'CREATE TABLE ' + @JSONtable + 
'(
	DataEntry VARCHAR(MAX)
)'

EXEC (@sql)

SET @sql = 
'INSERT INTO ' + @JSONtable + 
'(DataEntry) VALUES (''['')'
EXEC (@sql)

SET @SQL = 
'SELECT Column_Name INTO ##Columns FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = N''' + SUBSTRING(@sourceTable, 5, 100) + ''' AND COLUMNPROPERTY(object_id(TABLE_NAME), COLUMN_NAME, ''IsIdentity'') = 0'	

EXEC(@sql)

ALTER TABLE ##Columns
ADD ID INT IDENTITY(1,1) NOT NULL

DECLARE @count INT = 1
WHILE @count <= (SELECT max(ID) FROM ##Columns)
	BEGIN
		SET @columnList = @columnList + (SELECT Column_Name FROM ##Columns WHERE ID = @count) + ','
		SET @count = @count + 1
	END

DECLARE @columnListLength int = LEN(@columnList)

SET @columnList = LEFT(@columnList, @columnListLength-1)

SET @sql = 'SELECT ' + @columnList + ' INTO ##SourceTable FROM ' + @sourceTable
EXEC (@sql)

ALTER TABLE ##SourceTable
ADD ID INT IDENTITY(1,1) NOT NULL

DECLARE @sourceCount int = 1
DECLARE @columnCount int = 1
DECLARE @colName varchar(max)
DECLARE @value nvarchar(max)
DECLARE @JSONvalue nvarchar(MAX)

WHILE @sourceCount <= (SELECT max(ID) FROM ##SourceTable)
BEGIN
	
	SET @sql = 'INSERT INTO ' + @JSONtable + 
				'(DataEntry) VALUES (''{'')'
	EXEC (@sql)

	SET @columnCount = 1
	WHILE @columnCount <= (SELECT max(ID) FROM ##Columns)
		BEGIN
			SET @colName = (SELECT COLUMN_NAME FROM ##Columns WHERE ID = @columnCount)
			
			SET @sql = 'SELECT @value = (SELECT ' + @colName + ' FROM ##SourceTable WHERE ID = ' + CAST(@sourceCount AS VARCHAR) + ')'

			EXEC sp_executesql @sql, N'@value NVARCHAR(MAX) OUT', @value OUT

			SET @value = ISNULL(@value, 'NULL')

			IF @columnCount <> (SELECT MAX(ID) FROM ##Columns)
				BEGIN

					SET @JSONvalue = '"' + STRING_ESCAPE(@colName, 'JSON') + '": ' + '"' + STRING_ESCAPE(@value, 'JSON') + '",'
					SET @JSONvalue = REPLACE(@JSONvalue, '''', '''''')
					SET @sql = 'INSERT INTO ' + @JSONtable + 
							   '(DataEntry) VALUES (''' + @JSONvalue + ''')'
					EXEC (@sql)

				END
			ELSE
				BEGIN

					SET @JSONvalue = '"' + STRING_ESCAPE(@colName, 'JSON') + '": ' + '"' + STRING_ESCAPE(@value, 'JSON') + '"'
					SET @JSONvalue = REPLACE(@JSONvalue, '''', '''''')
					SET @sql = 'INSERT INTO ' + @JSONtable + 
							 '(DataEntry) VALUES (''' + @JSONvalue + ''')'
				    EXEC (@sql)

				END

			SET @columnCount = @columnCount + 1
		END
	IF @sourceCount < (SELECT MAX(ID) FROM ##SourceTable)
		BEGIN
			SET @sql = 'INSERT INTO ' + @JSONtable + 
						'(DataEntry) VALUES (''},'')'
			EXEC (@sql)
		END
	ELSE
		BEGIN
			SET @sql = 'INSERT INTO ' + @JSONtable + 
						'(DataEntry) VALUES (''}'')'
			EXEC (@sql)			
		END
	SET @sourceCount = @sourceCount + 1
END

SET @sql = 'INSERT INTO ' + @JSONtable + 
			'(DataEntry) VALUES ('']'')'
EXEC (@sql)
END
GO
