--Replace <Customer> with Operator name

DECLARE @SQL VARCHAR(8000)
DECLARE @Customer VARCHAR(255)
DECLARE @CustomerNM VARCHAR(255)

SET @Customer='AMIDEV'
SET @CustomerNM='SPECTRUM'

SET @SQL='
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = '''+@CustomerNM+'_TSK_ADHOC'',ClientID='''+@CustomerNM+''' WHERE SettingName = ''AdhocDBName''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = '''+@CustomerNM+'_TSK_IM'',ClientID='''+@CustomerNM+''' WHERE SettingName = ''IMDBName''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = '''+@CustomerNM+'_TSK_RPT'',ClientID='''+@CustomerNM+''' WHERE SettingName = ''ReportingDBName''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = ''C:\TEMP\ClientUploads'',ClientID='''+@CustomerNM+''' WHERE SettingName = ''TyskieUploadPath''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET CLIENTID = '''+@CustomerNM+''' WHERE CLIENTID IS NULL OR CLIENTID <> '''+@CustomerNM+'''
'
--PRINT @SQL
EXEC(@SQL)

/*
SELECT * FROM amidev_TSK.TSK.tblCfgSetting
*/

