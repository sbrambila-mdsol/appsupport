USE TPS_DBA
GO

IF NOT EXISTS ( SELECT 1 FROM TPS_DBA..tblServerSetting WHERE SettingName like 'IssueTicketAssignee' )
BEGIN
	INSERT INTO TPS_DBA..tblServerSetting([SettingDescription],[SettingName])
	VALUES('IssueTicketAssignee','IssueTicketAssignee')
END

