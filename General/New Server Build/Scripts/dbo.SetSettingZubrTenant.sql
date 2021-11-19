EXEC TPS_DBA.dbo.uspSetServerSetting
			@SettingName = 'Zubr Tenant',
			@SettingValue = '<TenantID>'--change to customer tenant value


SELECT *
FROM TPS_DBA.dbo.tblServerSetting
WHERE SettingName='Zubr Tenant'