USE [TPS_DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspGrantRevokeReadOnlyAccess]    Script Date: 5/29/2018 10:05:45 AM ******/
IF OBJECT_ID('uspGrantRevokeReadOnlyAccess','P') IS NOT NULL DROP PROCEDURE [dbo].[uspGrantRevokeReadOnlyAccess]
GO

/****** Object:  StoredProcedure [dbo].[uspGrantRevokeReadOnlyAccess]    Script Date: 5/29/2018 10:05:45 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create PROCEDURE [dbo].[uspGrantRevokeReadOnlyAccess] @LoginGroup varchar(255),  @AccessType VARCHAR(25)
/*******************************************************************************************
Purpose: To give read access to locked databases to a specific group/role at the database level
Inputs:		
Author:	Todd Forman	
Created: 5/15/18	
Copyright:	
RunTime:	
Execution:	
					EXEC uspGrantRevokeReadOnlyAccess 'TPSINTERNAL\EC2 DB Group','Add'
					EXEC uspGrantRevokeReadOnlyAccess 'TPSINTERNAL\EC2 DB Group','Drop'
					EXEC uspGrantRevokeReadOnlyAccess 'TPSINTERNAL\EC2 DB Group','Add'
					EXEC uspGrantRevokeReadOnlyAccess 'TPSINTERNAL\EC2 BA Group','Add'
					EXEC uspGrantRevokeReadOnlyAccess 'TPSINTERNAL\EC2 BA Group','Drop'
					EXEC uspGrantRevokeReadOnlyAccess 'TPSINTERNAL\EC2 BI Group','Add'
					EXEC uspGrantRevokeReadOnlyAccess 'TPSINTERNAL\EC2 BI Group','Drop'
					EXEC uspGrantRevokeReadOnlyAccess 'TPSINTERNAL\EC2 Dev Group','Add'
					EXEC uspGrantRevokeReadOnlyAccess 'TPSINTERNAL\EC2 Dev Group','Drop'
					EXEC uspGrantRevokeReadOnlyAccess 'AgileDWorkbench','Add'
					EXEC uspGrantRevokeReadOnlyAccess 'AgileDWorkbench','Drop'
					
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM 
					
					---- Staging Tables:
						SELECT * FROM 

					---- Reporting Tables:
						SELECT * FROM 
						



*******************************************************************************************/

AS

DECLARE @SQL VARCHAR(8000)

BEGIN
	SET NOCOUNT ON 

	--Place code in between Code Start and Code End
	--------
	------
	--Code Start

----------create check table to store current rights
DECLARE @DB_USers TABLE
(DBName sysname, UserName sysname, LoginType sysname, AssociatedRole varchar(max),create_date datetime,modify_date datetime)

 
INSERT @DB_USers
EXEC sp_MSforeachdb
 
'
use [?]
SELECT ''?'' AS DB_Name,
case prin.name when ''dbo'' then prin.name + '' (''+ (select SUSER_SNAME(owner_sid) from master.sys.databases where name =''?'') + '')'' else prin.name end AS UserName,
prin.type_desc AS LoginType,
isnull(USER_NAME(mem.role_principal_id),'''') AS AssociatedRole ,create_date,modify_date
FROM sys.database_principals prin
LEFT OUTER JOIN sys.database_role_members mem ON prin.principal_id=mem.member_principal_id
WHERE prin.sid IS NOT NULL and prin.sid NOT IN (0x00) and  
prin.is_fixed_role <> 1 AND prin.name NOT LIKE ''##%'''
 
SELECT dbname,username ,logintype ,create_date ,modify_date ,
 
STUFF(
( 
SELECT ',' + CONVERT(VARCHAR(500),associatedrole)
FROM @DB_USers user2
WHERE  
user1.DBName=user2.DBName AND user1.UserName=user2.UserName
FOR XML PATH('')
)
,1,1,'') AS Permissions_user
into #check 
FROM @DB_USers user1
WHERE USERNAME = @LoginGroup
GROUP BY dbname,username ,logintype ,create_date ,modify_date
ORDER BY DBName,username

--SELECT * FROM #check
	
	--------
	BEGIN TRY

	DECLARE @DbName varchar(255)
	
	--databases to assign rights to
	DECLARE DatabaseName_cursor CURSOR FOR
	SELECT NAME 
	FROM master.SYS.DATABASES 
	WHERE is_read_only = 0 --AND NAME NOT IN ('TempDb')
	ORDER BY NAME

	OPEN DatabaseName_cursor
	FETCH NEXT FROM DatabaseName_cursor INTO @DbName

	
	WHILE @@FETCH_STATUS=0
	BEGIN
	--read only access adds
		--other rights exist on db, but not datareader so add datareader role 
		IF EXISTS(SELECT DBNAME FROM #CHECK WHERE DBNAME=@dbname AND Permissions_user NOT LIKE '%db_datareader%') AND @AccessType='Add'
		BEGIN
		SET @SQL='
			--GRANT
			USE '+@dbname+' ALTER ROLE [db_datareader] '+@AccessType+' MEMBER ['+@LoginGroup+']'
			--PRINT @SQL
			EXEC(@SQL)
		END
		--no rights exist on db so add datareader login and role
		ELSE 
		IF NOT EXISTS(SELECT DBNAME FROM #CHECK WHERE DBNAME=@dbname AND Permissions_user LIKE '%db_datareader%') AND @AccessType='Add'
		BEGIN
			SET @SQL='
			--GRANT
				USE '+@dbname+' CREATE USER ['+@LoginGroup+'] FOR LOGIN ['+@LoginGroup+']
				USE '+@dbname+' ALTER ROLE [db_datareader] '+@AccessType+' MEMBER ['+@LoginGroup+']'
			--PRINT @SQL
			EXEC(@SQL)
		END

	--sqlagent reader role add for db on msdb 
		IF NOT EXISTS(SELECT DBNAME FROM #CHECK WHERE DBNAME=@dbname AND Permissions_user NOT LIKE '%SQLAgentReaderRole%') AND @AccessType='ADD' and @DbName='msdb' and @LoginGroup='TPSINTERNAL\EC2 DB Group'
			BEGIN
				SET @SQL='
				--GRANT
				USE '+@dbname+' ALTER ROLE [SQLAgentReaderRole] '+@AccessType+' MEMBER ['+@LoginGroup+']'
				--PRINT @SQL
				EXEC(@SQL)
			END

	--sqlagent reader role add for BA on msdb 
		IF NOT EXISTS(SELECT DBNAME FROM #CHECK WHERE DBNAME=@dbname AND Permissions_user NOT LIKE '%SQLAgentReaderRole%') AND @AccessType='ADD' and @DbName='msdb' and @LoginGroup='TPSINTERNAL\EC2 BA Group'
			BEGIN
				SET @SQL='
				--GRANT
				USE '+@dbname+' ALTER ROLE [SQLAgentReaderRole] '+@AccessType+' MEMBER ['+@LoginGroup+']'
				--PRINT @SQL
				EXEC(@SQL)
			END

	--drop rights
		--only datareader rights exist on db so drop datareader and login both
		IF EXISTS(SELECT DBNAME FROM #CHECK WHERE DBNAME=@dbname AND Permissions_user = 'db_datareader') AND @AccessType='DROP'
			BEGIN
				SET @SQL='
				--Revoke
				USE '+@dbname+' ALTER ROLE [db_datareader] '+@AccessType+' MEMBER ['+@LoginGroup+']
				USE '+@dbname+' DROP USER ['+@LoginGroup+']'
				--PRINT @SQL
				EXEC(@SQL)
			END
		ELSE
			--other rights exist on the db so only drop datareader role
			IF EXISTS(SELECT DBNAME FROM #CHECK WHERE DBNAME=@dbname AND Permissions_user LIKE '%db_datareader%') AND @AccessType='DROP'
			BEGIN
				SET @SQL='
				--Revoke
				USE '+@dbname+' ALTER ROLE [db_datareader] '+@AccessType+' MEMBER ['+@LoginGroup+']'
				--PRINT @SQL
				EXEC(@SQL)
			END
	FETCH NEXT FROM DatabaseName_cursor INTO @DbName 
	END
	CLOSE DatabaseName_cursor
	DEALLOCATE DatabaseName_cursor
	END TRY

	
	--------
	--Code End
	--------	
	
	-----------
	--Logging
	-----------	
	BEGIN CATCH
		----------
		--Update table variable with error message
			SELECT
				ERROR_NUMBER() AS ErrorNumber
				,ERROR_SEVERITY() AS ErrorSeverity
				,ERROR_STATE() AS ErrorState
				,ERROR_PROCEDURE() AS ErrorProcedure
				,ERROR_LINE() AS ErrorLine
				,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH





END




GO


