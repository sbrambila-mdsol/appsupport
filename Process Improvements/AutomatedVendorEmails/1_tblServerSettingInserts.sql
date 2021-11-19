IF NOT EXISTS (SELECT * FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SendVendorEmails')
	BEGIN
		INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription, SettingName, SettingValue)
		VALUES ('Binary flag to send late file emails externally', 'SendVendorEmails', '1')
	END

USE PROCESSING_DB
IF NOT EXISTS (SELECT * FROM agd.tblMdSetting WHERE Settingname = 'DataDateLogic')
	BEGIN 
		INSERT INTO agd.tblMdSetting (SettingDescription, SettingName, SettingValue)
		VALUES ('Number of days behind current day that Database DataDate is set to during normal operations', 'DataDateLogic', '0') 	
	END
