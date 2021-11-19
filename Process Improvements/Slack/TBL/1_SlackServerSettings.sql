USE TPS_DBA

DECLARE @CHANNEL VARCHAR(20)    -- CAN BE POPULATED TO OVERRIDE CHANNEL AUTOPOPULATE 
Declare @Environment varchar(50) =(select settingvalue from TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'Environment')

IF NOT EXISTS (
		SELECT 1
		FROM TPS_DBA..tblServerSetting
		WHERE settingname = 'SlackBotName'
		)
BEGIN
	INSERT INTO TPS_DBA..tblServerSetting (
		SettingName
		,SettingDescription
		,SettingValue
		)
	VALUES (
		'SlackBotName'
		,'Name of Slack Bot for Notifications'
		,'Optimus Prod' --Can Be Changed
		)
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

IF NOT EXISTS (
		SELECT *
		FROM TPS_DBA..tblServerSetting
		WHERE settingname = 'SlackCompletionChannel'
		)
BEGIN
	INSERT INTO TPS_DBA..tblServerSetting (
		SettingName
		,SettingDescription
		,SettingValue
		)
	VALUES (
		'SlackCompletionChannel'
		,'Name of Slack Channel for Notifications'
		, case when @channel is not null then @channel else case when @Environment in ('Production','Processing') then (SELECT + '#' + (select SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like '%client%name%') + '_prod') WHEN @Environment like '%qa%' THEN (SELECT + '#' + (select SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like '%client%name%')) WHEN @ENVIRONMENT  LIKE 'DEV%' THEN (SELECT + '#' + (select SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like '%client%name%') + '_TECH') ELSE NULL end end --If not populated can be left blank, no notification sent, Dev/QA environments for example, must use # symbol in front, can take a comma separated list, ie #ultragenyx,#ultragenyx_prod.
		)
END

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
		, case when @channel is not null then @channel else case when @Environment in ('Production','Processing') then '#prod_bot' WHEN @Environment like '%qa%' THEN (SELECT + '#' + (select SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like '%client%name%')) WHEN @ENVIRONMENT  LIKE 'DEV%' THEN (SELECT + '#' + (select SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like '%client%name%') + '_TECH') ELSE NULL end end  --If not populated can be left blank, no notification sent, Dev/QA environments for example, must use # symbol in front, can take a comma separated list, ie #ultragenyx,#ultragenyx_prod.
		)
END

IF NOT EXISTS (
		SELECT *
		FROM TPS_DBA..tblServerSetting
		WHERE settingname = 'SlackAppServicesChannel'
		)
BEGIN
	INSERT INTO TPS_DBA..tblServerSetting (
		SettingName
		,SettingDescription
		,SettingValue
		)
	VALUES (
		'SlackAppServicesChannel'
		,'Name of Slack Channel for application services Notifications'
		,'#application_services' --If not populated can be left blank, no notification sent, Dev/QA environments for example, must use # symbol in front, can take a comma separated list, ie #ultragenyx,#ultragenyx_prod.
		)
END

IF NOT EXISTS (
		SELECT 1
		FROM TPS_DBA..tblServerSetting
		WHERE settingname = 'SlackURL'
		)
BEGIN
	INSERT INTO TPS_DBA..tblServerSetting (
		SettingName
		,SettingDescription
		,SettingValue
		)
	VALUES (
		'SlackURL'
		,'Slack Webhook URL'
		,'https://hooks.slack.com/services/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' -- Do not change.
		)
END


  UPDATE TPS_DBA.dbo.tblServerSetting SET SettingValue = 'https://hooks.slack.com/services/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' WHERE Settingname = 'SlackURL'
  --TO UPDATE OLD SETTING VALUE


IF @@SERVERNAME like 'pro%'
BEGIN 
	IF NOT EXISTS (
			SELECT *
			FROM TPS_DBA..tblServerSetting
			WHERE settingname = 'SlackIcon'
			)
	BEGIN
		INSERT INTO TPS_DBA..tblServerSetting (
			SettingName
			,SettingDescription
			,SettingValue
			)
		VALUES (
			'SlackIcon'
			,'Slack Icon Image'
			,':autobot:' --Can be changed. Must use : on either side of image name.
			)
	END
END

IF @@SERVERNAME like 'prd%'
BEGIN 
	IF NOT EXISTS (
			SELECT *
			FROM TPS_DBA..tblServerSetting
			WHERE settingname = 'SlackIcon'
			)
	BEGIN
		INSERT INTO TPS_DBA..tblServerSetting (
			SettingName
			,SettingDescription
			,SettingValue
			)
		VALUES (
			'SlackIcon'
			,'Slack Icon Image'
			,':autobotblack:' --Can be changed. Must use : on either side of image name.
			)
	END
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

