USE [TPS_DBA]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

DECLARE @Customer VARCHAR(255)
DECLARE @CustomerLower VARCHAR(255)
DECLARE @CustAbb VARCHAR(5)
DECLARE @Environment VARCHAR(255) --Development, Processing, QA, Production
DECLARE @SQL VARCHAR(8000)

SET @Customer = '<Customer>'--'GSK'
SET @Customerlower = LOWER(@Customer)
SET @CustAbb=LEFT(@Customer,3)
SET @Environment='<Environment>'--'Development','Production','Processing','UAT'

SET @SQL='

--select * from tps_dba.dbo.tblserversetting

EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''Environment'',
									@SettingValue	= '''+@Environment+'''
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''AutoServerShutdown'',
									@SettingValue	= ''True''
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''DefaultReceipt'',
									@SettingValue	= ''ShyftProdTeam@shyftanalytics.com''
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''ArchivePath'',
									@SettingValue	= ''\\PRD'+@CustAbb+'10DB1\g$\MSSQL\Backup\'+@Environment+'''
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''DevServer'',
									@SettingValue	= ''DEV'+@CustAbb+'10DB1''
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''CSharpLoaderServerName'',
									@SettingValue	= ''DEV'+@CustAbb+'10DB1''
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''ProcessingServer'',
									@SettingValue	= ''PRO'+@CustAbb+'10DB1'' 
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''MobileServer'',
									@SettingValue	= ''PRD'+@CustAbb+'10DB1'' 
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''AdhocServer'',
									@SettingValue	= ''PRD'+@CustAbb+'10DB1'' 
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''QAServer'',
									@SettingValue	= ''QA'+@CustAbb+'10DB1'' 
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''ProductionServer'',
									@SettingValue	= ''PRD'+@CustAbb+'10DB1'' 
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''UATServer'',
									@SettingValue	= ''UAT'+@CustAbb+'10DB1'' 
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''URLDomain'',
									@SettingValue	= '''+@CustomerLower+'.shyftanalytics.com'' 
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''ClientName'',
									@SettingValue	= '''+@Customer+'''
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''TyskieDB'',
									@SettingValue	= '''+@Customer+'_TSK''
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''CommandCenterSyncServer'',
									@SettingValue	= ''PRD'+@CustAbb+'10DB1'' 
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''FilePurge_FilesFolderToPurgeFrom'',
									@SettingValue	= ''\\PRD'+@CustAbb+'10DB1\g$\MSSQL\Backup\'' 
									'
PRINT @SQL

/*
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= 'auth0ClientId',
									@SettingValue	= 'QnsLam3jWJ1qnybbLrb0ajUjF1M3qxhN' 
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= 'auth0Domain',
									@SettingValue	= 'csdevqa.auth0.com' 
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= 'auth0ApiIdentifier',
									@SettingValue	= ''http://devepi10db1:80/api'
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= 'auth0APISecret',
									@SettingValue	= 'qHwJsy8oDoF-tTYGmSW5dnOPMNws4d1Pr96ETOgbsghF0uT-kKm-cHAY9lsUqfuk' 
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= 'auth0APITenantId',
									@SettingValue	= 'g6BhmZOa48iTwPvKqlO2elgOAGcrbXh7' 



INSERT INTO [EPIZYME_TSK].[TSK].[tblUser] (AUTH0USERID,USERNAME,EMAIL,DISPLAYNAME,ACTIVE)
VALUES ('auth0|5b50da0df7ac1b2c6128365e','TForman@shyftanalytics.com','TForman@shyftanalytics.com','Todd Forman',1)

select * from [EPIZYME_TSK].[TSK].[tblUser]

--insert user role
INSERT INTO [EPIZYME_TSK].TSK.tblUserRole
VALUES (1,1)

SELECT *
FROM [EPIZYME_TSK].[TSK].[tblUserRole]

SELECT *
FROM [EPIZYME_TSK].TSK.vwUserPermission
*/