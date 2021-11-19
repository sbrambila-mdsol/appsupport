USE TPS_DBA
GO

IF NOT EXISTS ( SELECT 1 FROM TPS_DBA..tblServerSetting WHERE SettingName like 'JiraProjectName' )
BEGIN
	INSERT INTO TPS_DBA..tblServerSetting([SettingDescription],[SettingName])
	VALUES('JiraProjectName','JiraProjectName')
END

