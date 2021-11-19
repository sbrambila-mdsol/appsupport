USE TPS_DBA
DECLARE @CHANNEL VARCHAR(20)    -- CAN BE POPULATED TO OVERRIDE CHANNEL AUTOPOPULATE 
Declare @Environment varchar(50) =(select settingvalue from TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'Environment')

--Add settings to tps_dba
  IF NOT EXISTS (SELECT 1 FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SlackBotCompletionName')
  BEGIN
    DECLARE @BotName VARCHAR(50) 
    SET @BotName = 'Optimus Prod'
    INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription, SettingName, SettingValue)
    VALUES ('Name of Slack Bot for job completion notifications', 'SlackBotCompletionName', @BotName)
  END
  IF NOT EXISTS (SELECT 1 FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SlackCompletionChannel')
  BEGIN
    INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription, SettingName, SettingValue)
    VALUES ('Name of Slack Channel for job completion Notifications', 'SlackCompletionChannel', case when @channel is not null then @channel else case when @Environment in ('Production','Processing') then (SELECT + '#' + (select SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like '%client%name%') + '_prod') WHEN @Environment like '%qa%' THEN (SELECT + '#' + (select SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like '%client%name%')) WHEN @ENVIRONMENT  LIKE 'DEV%' THEN (SELECT + '#' + (select SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like '%client%name%') + '_TECH') ELSE NULL end end)
  END

 -- delete from TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SlackURL'
  IF NOT EXISTS (SELECT 1 FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SlackURL')
  BEGIN
    INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription, SettingName, SettingValue)
    VALUES ('Slack Webhook URL', 'SlackURL', 'https://hooks.slack.com/services/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')
  END
  UPDATE TPS_DBA.dbo.tblServerSetting SET SettingValue = 'https://hooks.slack.com/services/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' WHERE Settingname = 'SlackURL'
  --TO UPDATE OLD SETTING VALUE

  IF NOT EXISTS (SELECT 1 FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SlackIcon')
  BEGIN
    INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription, SettingName, SettingValue)
    VALUES ('Slack Icon Image', 'SlackIcon', ':autobot:')
  END
IF NOT EXISTS (SELECT * FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SlackOnJobCompletion')
	BEGIN 
		INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription, SettingName, SettingValue)
		VALUES ('Jobs for which to notify prod channel of successful completion', 'SlackOnJobCompletion', NULL) 	
	END


IF NOT EXISTS (
		SELECT 1
		FROM TPS_DBA..tblServerSetting
		WHERE settingname = 'SlackBotCompletionName'
		)
BEGIN
	INSERT INTO TPS_DBA..tblServerSetting (
		SettingName
		,SettingDescription
		,SettingValue
		)
	VALUES (
		'SlackBotCompletionName'
		,'Name of Slack Bot for Notifications'
		,'Optimus Prod' --Can Be Changed
		)
END
 delete from TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SlackfailChannel'

IF NOT EXISTS (
		SELECT *
		FROM TPS_DBA..tblServerSetting
		WHERE settingname = 'SlackfailChannel'
		)
BEGIN
	INSERT INTO TPS_DBA..tblServerSetting (
		SettingName
		,SettingDescription
		,SettingValue
		)
	VALUES (
		'SlackfailChannel'
		,'Name of Slack Channel for failure Notifications'
		, case when @channel is not null then @channel else case when @Environment in ('Production','Processing') then '#prod_bot' WHEN @Environment like '%qa%' THEN (SELECT + '#' + (select SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like '%client%name%')) WHEN @ENVIRONMENT  LIKE 'DEV%' THEN (SELECT + '#' + (select SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like '%client%name%') + '_TECH') ELSE NULL end end --If not populated can be left blank, no notification sent, Dev/QA environments for example, must use # symbol in front, can take a comma separated list, ie #ultragenyx,#ultragenyx_prod.
		)
END

IF NOT EXISTS (
		SELECT *
		FROM TPS_DBA..tblServerSetting
		WHERE settingname = 'SlackSuccessIcon'
		)
BEGIN
	INSERT INTO TPS_DBA..tblServerSetting (
		SettingName
		,SettingDescription
		,SettingValue
		)
	VALUES (
		'SlackSuccessIcon'
		,'Slack Icon Image'
		,':autobotgreen:' --Can be changed. Must use : on either side of image name.
		)
END

SELECT * FROM TPS_DBA.dbo.tblServerSetting where settingname like '%slack%'

