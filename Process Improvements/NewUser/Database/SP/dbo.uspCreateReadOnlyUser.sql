USE [TPS_DBA]
GO
IF OBJECT_ID('dbo.uspCreateReadOnlyUser') IS NOT NULL 
    BEGIN 
        DROP PROCEDURE dbo.uspCreateReadOnlyUser 
    END
GO
/****** Object:  StoredProcedure [dbo].[uspCreateReadOnlyUser]    Script Date: 12/2/2019 3:00:33 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspCreateReadOnlyUser]
/*******************************************************************************************
Name:               uspCreateReadOnlyUser
Purpose:            Creates a Read-Only user (typically for a customer) on a provided set of databases.
Inputs:             None
Author:             Mike Araujo
Created:            11th Nov 2019
History:            Date                Name                Comment
                    11th Nov 2019       Mike Araujo      Initial Creation
					13th Dec 2019		Todd Forman		 Remove code to drop user
					25th Feb 2021		David Malfetano	 XML permission sync for backup/restore adhoc process
					18th May 2021		Todd Forman	     Add logic for restore type

Copyright:
RunTime:            00:00:01 (HH:MM:SS)

Execution:         EXEC TPS_DBA.dbo.uspCreateReadOnlyUser 'TGTHERAPEUTICS_ADHOC', 'TGTHERAPEUTICS', 'TEST_USER', '1235!#$^@$%&45863', 'userpermissions_adhoc'

SAMPLE VARIABLE FOR TESTING:

	declare @TargetDatabase varchar(max) = 'COHERUS_ADHOC'
	declare @ProcessingDB varchar(max)= 'COHERUS'
	declare @UserName varchar(max) = 'TEST_USER'
	declare @Password varchar(max)= '1235!#$^@$%&458637546dhrtw#$%&*^&(^&)'
	declare @UserPermissionsSettingName varchar(max)= 'userpermissions_rpt'

*******************************************************************************************/
 @TargetDatabase VARCHAR(MAX)
,@ProcessingDB varchar(MAX) = NULL
,@UserName VARCHAR(MAX)
,@Password VARCHAR(MAX)
,@UserPermissionsSettingName VARCHAR(MAX) = NULL

AS
BEGIN
	SET	NOCOUNT ON

	--Declaring variables
	DECLARE @SQL NVARCHAR(MAX)
	DECLARE @Valid int = 1
	DECLARE @CreateNewServerUser NVARCHAR(MAX)
	DECLARE @CreateNewDBUser NVARCHAR (MAX)
	DECLARE @DropCreateNewUser NVARCHAR (MAX)
	DECLARE @UpdateUserPermissions varchar(MAX) 
	DECLARE @Environment varchar(MAX) =	TPS_DBA.dbo.udfGetServerSetting ('Environment')  
	DECLARE @permissionXML VARCHAR(200) = '<UserPermissions><UserName>' + @Username + '</UserName><UserRole>db_datareader</UserRole></UserPermissions>'
	DECLARE @ClientName VARCHAR(50) = TPS_DBA.dbo.udfGetServerSetting ('ClientName') 
	DECLARE @RestoreType varchar(25)=SUBSTRING(@TargetDatabase,PATINDEX('%[_]%',@TargetDatabase)+1,LEN(@TargetDatabase)-PATINDEX('%[_]%',@TargetDatabase))	
	
	--Raise error if password not specified
	IF (SELECT @Password) IS NULL
		BEGIN
			RAISERROR ('Password not specified. Please specify a username', 16, 1)
			SET @Valid = 0
		END

	--Raise error if username not specified
	IF (SELECT @UserName) IS NULL
		BEGIN
			RAISERROR ('Username not specified. Please specify a username', 16, 1)
			SET @Valid = 0
		END

	--Raise error if specified database doesn't exist on server (i.e. you're on the wrong server)
	IF (SELECT DB_ID(@TargetDatabase)) IS NULL
		BEGIN
			RAISERROR ('Target database not specified or does not exist on this server.', 16, 1)
			SET @Valid = 0
		END
	
	--Raise error if processing database doesn't exist on server (i.e. you're on the wrong server)
	IF @Environment in ('Processing', 'UAT', 'QA', 'DEV', 'Development') 
	BEGIN
		IF (SELECT DB_ID(@ProcessingDB)) IS NULL
			BEGIN
				RAISERROR ('Processing database not specified or does not exist on this server.', 16, 1)
				SET @Valid = 0
			END
	END
	
	--If first checks pass
	IF @Valid = 1 
		BEGIN
				IF @Environment in ('Processing', 'UAT', 'QA', 'DEV', 'Development') 
					BEGIN
						--Raise error if no settingName or incorrect settingName specified
						SET @SQL = 
						'IF (SELECT 1 from ' + @ProcessingDB + '.AGD.tblMdSetting where settingName = ''' + ISNULL(@UserPermissionsSettingName, 'NULL') + ''') IS NULL
							BEGIN
								SET @Valid = 0
								RAISERROR (''incorrect user permissions settingName or user permissions settingName not defined. Please check agd.tblmdsetting for appropriate settingName'', 16, 1)
							END
						 ELSE 
							BEGIN
								SET @Valid = 1
							END'
						EXEC SP_EXECUTESQL @SQL, N'@Valid int OUT', @Valid OUT
					END
			
			--If all checks pass
			IF @Valid = 1
				BEGIN
					--DROP AND CREATE NEW SERVER LEVEL USER
					SET @DropCreateNewUser = 
							'USE [master] 
							 IF NOT EXISTS (SELECT 1 FROM master.sys.syslogins WHERE name = '''+@UserName+ ''') 
								BEGIN 
									CREATE LOGIN [' + @UserName + '] WITH PASSWORD=N''' + @Password + ''', 
									DEFAULT_Database=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
								END'
					EXEC (@DropCreateNewUser)

					--Drop and Create user login for DB
					SET @CreateNewDBUser = 
						'USE ' + @TargetDatabase +
						' IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = ''' + @UserName + ''' AND Type IN (''U'',''S'',''G'')) 
							 BEGIN
								CREATE USER [' + @Username + '] FOR LOGIN [' + @UserName + '] 
								ALTER USER [' + @Username + '] with DEFAULT_SCHEMA=[dbo]  
								ALTER ROLE [db_datareader] ADD MEMBER [' + @Username + ']
							 END'	 
					EXEC (@CreateNewDBUser)

				--Update Permissions XML
					IF @Environment in ('Processing', 'UAT', 'QA', 'DEV', 'Development') 
						BEGIN
							DROP TABLE IF EXISTS ##permissions
							DECLARE @settingValue int

							SET @SQL = 'SELECT ' + @ProcessingDB + '.AGD.udfGetSetting(''' + @UserPermissionsSettingName + ''') as settingValue INTO ##permissions'
							EXEC (@SQL)

							IF (SELECT 1 FROM ##permissions WHERE settingValue IS NULL OR settingValue = '') = 1
								BEGIN
									SET @UpdateUserPermissions = 'UPDATE ' + @ProcessingDB + '.AGD.tblMdSetting SET settingValue = ''<root>'' + ''' + @permissionXML + ''' + ''</root>''
									WHERE settingName = ''' + @UserPermissionsSettingName + ''''
									EXEC (@updateuserpermissions)

									SET @UpdateUserPermissions = ' UPDATE TPS_DBA.dbo.tblMdBackupRestoreAdhoc '
																+' SET UserPermission = ''<root>'' + ''' + @permissionXML + ''' + ''</root>'''
																+' WHERE RestoreType = '''+@RestoreType+''''
									EXEC (@updateuserpermissions)
								END
							ELSE
								BEGIN		
									SET @SQL = 'SELECT @settingValue = 1 FROM ##permissions where settingValue like ''%' + @permissionXML + '%'''
									EXEC SP_EXECUTESQL @SQL, N'@settingValue int OUT', @settingValue OUT

									IF @settingValue IS NULL
									BEGIN
										SET @UpdateUserPermissions = 'UPDATE ' + @ProcessingDB + '.AGD.tblMdSetting SET settingValue = (
													SELECT REPLACE(ISNULL(' + @ProcessingDB + '.AGD.udfGetSetting(''' + @UserPermissionsSettingName + '''), ''''), ''</root>'', '''') + ''' + @permissionXML + ''' + ''</root>'')
													WHERE settingName = ''' + @UserPermissionsSettingName + ''''
										EXEC (@UpdateUserPermissions)

										SET @UpdateUserPermissions = ' UPDATE TPS_DBA.dbo.tblMdBackupRestoreAdhoc '
																	+' SET UserPermission = (SELECT REPLACE(ISNULL(' + @ProcessingDB + '.AGD.udfGetSetting(''' + @UserPermissionsSettingName + '''), ''''), ''</root>'', '''') + ''' + @permissionXML + ''' + ''</root>'')'
																	+' WHERE RestoreType = '''+@RestoreType+''''
										EXEC (@updateuserpermissions)
									END
								END
						END

					IF @Environment in ('Processing') 
						BEGIN
							--DISABLE USER ON PROCESSING ENVIRONMENT
								DECLARE @DisableSingleSQLUsers VARCHAR(max) = 
								'USE MASTER ALTER LOGIN [' + @UserName + '] DISABLE
								USE MASTER DENY CONNECT SQL TO [' + @UserName + ']'
								EXEC (@DisableSingleSQLUsers)
						END
				END
		END
END
GO


