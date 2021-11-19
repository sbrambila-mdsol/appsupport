--Development
--Processing
--Production
--QA
--UAT

/*
I think we are ok with having 1 copy of DEV and UAT and 3 copies of QA
*/

DECLARE @ENV  VARCHAR(255)
DECLARE @ProdServer VARCHAR(255)
DECLARE @SQL VARCHAR(8000)
DECLARE @DaystoPurge VARCHAR(2)

SET @ENV=(Select Settingvalue from TPS_DBA.dbo.tblServerSetting where SettingName='Environment')
--print @env

SET @DaystoPurge= CASE WHEN @ENV='UAT' THEN 1 WHEN @ENV='DEVELOPMENT' THEN 1 WHEN @ENV='QA' THEN 3 ELSE 5 END
--PRINT @DaystoPurge

SET @ProdServer=(Select Settingvalue from TPS_DBA.dbo.tblServerSetting where SettingName='ProductionServer')
--print @ProdServer

--\\PRDSPPI10DB1\g$\MSSQL\Backup\Development
--\\PRDSPPI10DB1\mssql\Backup\Development

SET @SQL='
update TPS_DBA.dbo.tblServerSetting
set settingvalue=''\\'+@ProdServer+'\mssql\Backup\'+@ENV+'''
where settingname=''FilePurge_FilesFolderToPurgeFrom''

update TPS_DBA.dbo.tblServerSetting
set settingvalue='+@DaystoPurge+'
where settingname=''FilePurge_DaysOfFilesFolderToKeepAtAPath''

update TPS_DBA.dbo.tblServerSetting
set settingvalue=''txt,csv,xls,xlsx,zip,rar,bak''
where settingname=''FilePurge_FileExtensionsToPurge''
'
--PRINT @SQL
EXEC(@SQL)

select *
from TPS_DBA.dbo.tblServerSetting
where SettingName like '%purge%'
