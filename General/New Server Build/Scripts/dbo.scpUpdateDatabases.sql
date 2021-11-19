use TPS_DBA


-------************change <CustomerName> to appropriate Customer needed*******************

--check before
SELECT DB_NAME(database_id) AS DatabaseNameBefore, name AS LogicalFileNameBefore, physical_name AS PhysicalFileNameBefore
FROM sys.master_files AS mf

DECLARE @Customer VARCHAR(255)
DECLARE @SQL VARCHAR(8000)
SET @CUSTOMER='<Customer>'


--STEP 1 RENAME OPERATOR
SET @SQL='
exec msdb.dbo.sp_update_operator 
    @name = ''AMIDEV'', 
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

--Run job Util Rename Dev Databases

EXEC MSDB.dbo.sp_start_job N'Util Rename Dev Databases'

--check after
BEGIN  
    WAITFOR DELAY '00:00:07'  
SELECT DB_NAME(database_id) AS DatabaseNameAfter, name AS LogicalFileNameAfter, physical_name AS PhysicalFileNameAfter 
FROM sys.master_files AS mf
END  

----------
/*
--RENAME DBS
EXEC uspRenameDevDBs

--RENAME FILE
EXEC uspRenameDevDBFiles

--RENAME PHYS FILES
--powershell

--OFFLINE
EXEC uspRenameDevDBServerOnline

--RENAME LOGIGAL NAMES
EXEC uspRenameDevLogicalNames
*/