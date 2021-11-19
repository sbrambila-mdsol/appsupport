--Replace <Customer> with Operator name

DECLARE @SQL VARCHAR(8000)
DECLARE @Customer VARCHAR(255)

SET @Customer='<Customer>'

SET @SQL='
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = '''+@Customer+'_TSK_ADHOC'' WHERE SettingName = ''AdhocDBName''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = '''+@Customer+'_TSK_IM'' WHERE SettingName = ''IMDBName''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = '''+@Customer+'_TSK_RPT'' WHERE SettingName = ''ReportingDBName''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET SettingValue = ''C:\TEMP\ClientUploads'' WHERE SettingName = ''TyskieUploadPath''
UPDATE '+@Customer+'_TSK.TSK.tblCfgSetting SET CLIENTID = '''+@Customer+''' WHERE CLIENTID IS NULL OR CLIENTID <> '''+@Customer+'''
'
--PRINT @SQL
EXEC(@SQL)