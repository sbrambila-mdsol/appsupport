USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspLoadInstanceDatabasePermissions]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspLoadInstanceDatabasePermissions]
/*******************************************************************************************
Purpose:			Connects to a specified linked server and loads permissioning information into ApplicationServices DB
Inputs:				
Author:				Crichton
Created:			5/15/2018
Copyright:
RunTime:			~1 sec per row in instance table - longer if servers are off
Execution:			EXEC uspLoadInstanceDatabasePermissions 1,'10.151.56.103','5/15/2018'

History:			


*******************************************************************************************/
	@InstanceId INT,
	@LinkedServerName NVARCHAR(128),
	@AuditDate DATE
AS

BEGIN

	DECLARE @DynSQL NVARCHAR(MAX) = N''
	
	DELETE FROM ApplicationServices.dbo.CustomerInstanceServerUserRole
	WHERE		InstanceId = @InstanceId
	AND			AuditDate = @AuditDate

	SET @DynSql = N'
	INSERT INTO ApplicationServices.dbo.CustomerInstanceServerUserRole(	InstanceId ,AuditDate,SystemID  ,LoginName ,DefaultDatabase ,LoginType ,ADLoginType ,
														sysadmin,securityadmin,serveradmin,setupadmin,processadmin,diskadmin,dbcreator,bulkadmin )

	SELECT  ' + CAST(@InstanceId AS NVARCHAR(5)) + ',
			''' + CAST(@AuditDate AS NVARCHAR(20)) + ''',
			sid as SystemId,
			loginname AS [Login Name], 
			dbname AS [Default Database],
			CASE isntname 
				WHEN 1 THEN ''AD Login''
				ELSE ''SQL Login''
			END AS [Login Type],
			CASE 
				WHEN isntgroup = 1 THEN ''AD Group''
				WHEN isntuser = 1 THEN ''AD User''
				ELSE ''''
			END AS [AD Login Type],
			sysadmin,
			[securityadmin],
			[serveradmin],
			[setupadmin],
			[processadmin],
			[diskadmin],
			[dbcreator],
			[bulkadmin]

	FROM [' + @LinkedServerName + '].master.dbo.syslogins 
	'

	EXECUTE sp_executesql @DynSql 


	DECLARE @DBName             VARCHAR(60)
	Declare @DBID            varchar(3)
	DECLARE @ParamDefinition nvarchar(500)  = N'@LinkedServerName NVARCHAR(128), @DBID varchar(3) OUTPUT';
	SET @DynSql = N'SELECT @DBID = (SELECT MAX(database_id) from [' + @LinkedServerName + '].master.sys.databases)'

	EXECUTE sp_executesql @DynSql,@ParamDefinition ,@LinkedServerName=@LinkedServerName,@DBID=@DBID OUTPUT;

	
	DELETE FROM ApplicationServices.dbo.CustomerInstanceDatabaseUserRole
	WHERE		InstanceId = @InstanceId
	AND			AuditDate = @AuditDate


	WHILE @DBID != 0
	BEGIN
		SET @ParamDefinition = N'@DBID NVARCHAR(128),@LinkedServerName NVARCHAR(128), @DBName varchar(60) OUTPUT';
		SET @DynSql = N'SELECT @DBName=name FROM [' + @LinkedServerName + '].master.sys.databases where database_id=@DBID'
		EXECUTE sp_executesql @DynSql,@ParamDefinition ,@LinkedServerName=@LinkedServerName,@DBID=@DBID ,@DBName=@DBName OUTPUT;

	
	
		  SELECT @DynSql  = 'INSERT INTO CustomerInstanceDatabaseUserRole(InstanceId,AuditDate,DBName,DBUserId,ServerLogin,DBRole)
							  SELECT '+ CAST(@InstanceId AS NVARCHAR(10))  + ',  
							 ''' + CAST(@AuditDate AS NVARCHAR(20)) + ''', ''' + 
									@DBName + ''' AS [Database],' +
							 '       su.[name] AS [Database User ID], ' +
							 '       COALESCE (u.[LoginName], ''** Orphaned **'') AS [Server Login], ' +
							 '       COALESCE (sug.name, ''Public'') AS [Database Role] ' +
							 '    FROM [' + @LinkedServerName + '].[' + @DBName + '].[dbo].[sysusers] su' +
							 '        LEFT OUTER JOIN CustomerInstanceServerUserRole u' +
							 '            ON su.sid = u.SystemId' +
							 '        LEFT OUTER JOIN ([' + @LinkedServerName + '].[' + @DBName + '].[dbo].[sysmembers] sm ' +
							 '                             INNER JOIN [' + @LinkedServerName + '].[' + @DBName + '].[dbo].[sysusers] sug  ' +
							 '                                 ON sm.groupuid = sug.uid)' +
							 '            ON su.uid = sm.memberuid ' +
							 '    WHERE su.hasdbaccess = 1' +
							 '      AND su.[name] != ''dbo'' '
		BEGIN TRY 
			EXEC (@DynSql)
		END TRY
		BEGIN CATCH
			INSERT INTO ApplicationServices.dbo.CustomerInstancePermissionAuditError(InstanceId ,AuditDate ,DBName ,SQLStmt,ErrorMessage )
			SELECT		@InstanceId,@AuditDate,@DBName,@DynSQL,ERROR_MESSAGE()
		END CATCH
		SET @DBID = @DBID - 1
	END
END

GO
