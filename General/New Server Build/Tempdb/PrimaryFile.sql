USE master
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'tempdb')
BEGIN
	IF NOT EXISTS (SELECT 1 FROM tempdb.sys.database_files WHERE name = N'tempdev')
	BEGIN
		ALTER DATABASE tempdb 
		ADD FILE ( NAME = tempdev, FILENAME = N'F:\MSSQL\DATA\tempdb.mdf', SIZE = 20 GB, FILEGROWTH = 500MB)
		--ADD FILE ( NAME = tempdev, FILENAME = N'F:\MSSQL\DATA\tempdb.mdf', SIZE = 50 GB, FILEGROWTH = 1GB)
	END
	ELSE
	BEGIN
		ALTER DATABASE tempdb
		MODIFY FILE ( NAME = tempdev, FILENAME = N'F:\MSSQL\DATA\tempdb.mdf', SIZE = 20 GB, FILEGROWTH = 500MB)
		--MODIFY FILE ( NAME = tempdev, FILENAME = N'F:\MSSQL\DATA\tempdb.mdf', SIZE = 50 GB, FILEGROWTH = 1GB)
	END	

	ALTER DATABASE tempdb
	MODIFY FILE ( NAME = tempLog, FILENAME = 'E:\MSSQL\Log\tempdbLog.ldf')
END

--SELECT * FROM sys.databases WHERE name = N'tempdb'
--SELECT * FROM tempdb.sys.database_files