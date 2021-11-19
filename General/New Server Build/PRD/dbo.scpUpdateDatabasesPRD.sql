use TPS_DBA


-------************change <CustomerName> to appropriate Customer needed*******************

--check before
SELECT DB_NAME(database_id) AS DatabaseNameBefore, name AS LogicalFileNameBefore, physical_name AS PhysicalFileNameBefore
FROM sys.master_files AS mf

DECLARE @Customer VARCHAR(255)
DECLARE @SQL VARCHAR(8000)
SET @CUSTOMER='<CustomerName>'


--STEP 1 RENAME OPERATOR
SET @SQL='
exec msdb.dbo.sp_update_operator 
    @name = ''AMI'', 
    @new_name = '''+@CUSTOMER+'''

--STEP 2 UPDATE NAME OF OPERATOR SETTING
EXEC TPS_DBA.dbo.uspSetServerSetting
									@SettingName	= ''SQLServerAgentOperator'',
									@SettingValue	= '''+@CUSTOMER+'''
'
--PRINT @SQL
EXEC(@SQL)

PRINT 'SQLAGENTOPERATOR RENAMED AND SETTING UPDATED......'
select [dbo].[udfGetServerSetting]('SQLServerAgentOperator') AS OperatorNameAfter

--Run job Util Rename Databases

EXEC MSDB.dbo.sp_start_job N'Util Rename Databases'

--check after
BEGIN  
    WAITFOR DELAY '00:00:07'  
SELECT DB_NAME(database_id) AS DatabaseNameAfter, name AS LogicalFileNameAfter, physical_name AS PhysicalFileNameAfter 
FROM sys.master_files AS mf
END  

----------
/*
--RENAME DBS
EXEC tps_dba.dbo.uspRenameDBs

--RENAME FILE
EXEC tps_dba.dbo.uspRenameDBFiles

--RENAME PHYS FILES
--powershell

--OFFLINE
EXEC tps_dba.dbo.uspRenameDBServerOnline

--RENAME LOGIGAL NAMES
EXEC tps_dba.dbo.uspRenameLogicalNames
*/