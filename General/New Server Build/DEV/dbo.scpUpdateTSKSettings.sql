--Replace <Customer> with Operator name

DECLARE @SQL VARCHAR(8000)
DECLARE @Customer VARCHAR(255)

SET @Customer='<Customer>'

SET @SQL='
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = '''+@Customer+'_TSK_ADHOC'',ClientID='''+@Customer+''' WHERE SettingName = ''AdhocDBName''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = '''+@Customer+'_TSK_IM'',ClientID='''+@Customer+''' WHERE SettingName = ''IMDBName''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = '''+@Customer+'_TSK_RPT'',ClientID='''+@Customer+''' WHERE SettingName = ''ReportingDBName''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = ''C:\TEMP\ClientUploads'',ClientID='''+@Customer+''' WHERE SettingName = ''TyskieUploadPath''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET CLIENTID = '''+@Customer+''' WHERE CLIENTID IS NULL OR CLIENTID <> '''+@Customer+'''
'
--PRINT @SQL
EXEC(@SQL)

/*
SELECT * FROM EPIZYME_TSK.TSK.tblCfgSetting
*/

