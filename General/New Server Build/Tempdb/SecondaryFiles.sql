USE master
GO

--Total Number of tempdb files should be equal to number of processors upto 8 files
DECLARE @TotalNumberOfSecondaryFiles INT

SELECT	@TotalNumberOfSecondaryFiles = CASE WHEN cpu_count <= 8 THEN cpu_count ELSE 8 END
FROM	sys.dm_os_sys_info

--print @TotalNumberOfSecondaryFiles

DECLARE @COUNTER INT
DECLARE @SQL NVARCHAR(MAX)

IF	OBJECT_ID('dbo.TembdbFiles',  'U') IS NOT NULL
BEGIN
	DROP TABLE dbo.TembdbFiles
END

SELECT	Id = IDENTITY (INT, 1, 1)
		,Tempdb_Logical_FileName = CAST(name AS VARCHAR(200))
INTO	dbo.TembdbFiles
FROM	tempdb.sys.database_files
WHERE	name NOT IN ('tempdev', 'templog')

SET		@COUNTER = 1

WHILE	@COUNTER <= (SELECT MAX(Id) FROM dbo.TembdbFiles)
BEGIN
		DECLARE	@Tempdb_Logical_FileName NVARCHAR(200) = (SELECT Tempdb_Logical_FileName FROM dbo.TembdbFiles WHERE Id = @COUNTER)
		
		SET	@SQL = '
		USE	tempdb
		
		DBCC SHRINKFILE ('''+@Tempdb_Logical_FileName+''', EMPTYFILE); 
		
		ALTER DATABASE tempdb REMOVE FILE '+@Tempdb_Logical_FileName+'; '
		PRINT @SQL
		EXEC(@SQL)
		SET	@COUNTER+=1
END

USE	master

DECLARE @STRCOUNTER VARCHAR(2)

SET @COUNTER=2
SET @STRCOUNTER=CONVERT(VARCHAR(2),@COUNTER)

--orignally 50 gb and 1 gb growth
WHILE @COUNTER <= @TotalNumberOfSecondaryFiles
BEGIN
	
	SET @SQL='
	IF NOT EXISTS (SELECT 1 FROM tempdb.sys.database_files WHERE name =  N''tempdev'+@STRCOUNTER+''')
	BEGIN
		ALTER DATABASE tempdb 
		ADD FILE ( NAME = N''tempdev'+@STRCOUNTER+''', FILENAME = N''F:\MSSQL\DATA\tempdev'+@STRCOUNTER+'.ndf'' , SIZE = 20GB, FILEGROWTH = 500MB)
	END
	ELSE
	BEGIN
		ALTER DATABASE tempdb
		MODIFY FILE ( NAME = N''tempdev'+@STRCOUNTER+''', FILENAME = N''F:\MSSQL\DATA\tempdev'+@STRCOUNTER+'.ndf'', SIZE = 20GB, FILEGROWTH = 500MB)
	END
	'
	EXEC(@SQL)
	PRINT @SQL
	SET @COUNTER=@COUNTER+1
	SET @STRCOUNTER=CONVERT(NVARCHAR(2),@COUNTER)
END

--DROP TABLE dbo.TembdbFiles



GO