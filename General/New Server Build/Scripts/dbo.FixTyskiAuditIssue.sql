USE TPS_DBA
GO
DECLARE @DBNamePar varchar(100) = TPS_DBA.dbo.udfGetServerSetting('TyskieDB')
PRINT @DBNamePar
EXEC [TPS_DBA].[DBO].[uspGenerateAuditTriggers] @DBName=@DBNamePar, @Schemaname = 'tsk' ,@Tablename = 'tblFrontEndMap' ,@GenerateScriptOnly = 0
EXEC [TPS_DBA].[DBO].[uspGenerateAuditTriggers] @DBName=@DBNamePar, @Schemaname = 'tsk' ,@Tablename = 'tblCfgSetting' ,@GenerateScriptOnly = 0