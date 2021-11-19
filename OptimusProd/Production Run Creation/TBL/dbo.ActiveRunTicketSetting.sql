USE TPS_DBA
GO

IF NOT EXISTS (SELECT 1 FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName='ActiveRunTicket')
INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription,SettingName)
VALUES ('Active Production Run Ticket','ActiveRunTicket')
