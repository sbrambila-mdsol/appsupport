USE MASTER
GO
SELECT	DatabaseName		= DB_NAME(database_id), 
		LogicalFileName		= Name,
		PhysicalFileName	= Physical_Name
FROM	sys.master_files AS mf
WHERE	DB_NAME(database_id)='tempdb'
GO

-- Get the additoinal file name: might be named NDF extention.

USE TEMPDB
GO
DBCC SHRINKFILE ('temp2' , 0) -- shrink to 0 MB
GO
DBCC FREEPROCCACHE
GO
ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'temp2', SIZE = 0KB, FILEGROWTH = 0% );
GO
--  Stop and restart SQL Server.  
GO
ALTER DATABASE [tempdb] REMOVE FILE [temp2];
GO

SELECT	DatabaseName		= DB_NAME(database_id), 
		LogicalFileName		= Name,
		PhysicalFileName	= Physical_Name
FROM	sys.master_files AS mf
WHERE	DB_NAME(database_id)='tempdb'