USE [TPS_DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspAddSlackFailNotifications]    Script Date: 4/25/2019 2:35:14 PM ******/
IF OBJECT_ID('dbo.uspAddSlackFailNotifications', 'P') IS NOT NULL

DROP PROCEDURE [dbo].[uspAddSlackFailNotifications]
GO

/****** Object:  StoredProcedure [dbo].[uspAddSlackFailNotifications]    Script Date: 4/25/2019 2:35:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Mike Araujo
-- Create date: 10/11/2018
-- Description:	Adds a failure notification step to the end of all jobs. 
--              Modifies all steps to go to failure notification step upon failure
-- Execution: Exec [tps_dba].[dbo].[uspAddSlackFailNotifications]

--Modified url for slack on 6/25/20 in anticipation of conversion to mdsol slack - Todd Forman
-- =============================================
CREATE PROCEDURE [dbo].[uspAddSlackFailNotifications]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

--Add settings to tps_dba
  IF NOT EXISTS (SELECT 1 FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SlackBotName')
  BEGIN

	DECLARE @BotName VARCHAR(50) 
    SET @BotName = (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName = 'ClientName') + '_Bot'
	INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription, SettingName, SettingValue)
	VALUES ('Name of Slack Bot for Notifications', 'SlackBotName', @BotName)

  END

  IF NOT EXISTS (SELECT 1 FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SlackFailChannel')
  BEGIN
	Declare @Environment varchar(50) 
	set @Environment=(select settingvalue from TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'Environment')
	INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription, SettingName, SettingValue)
	VALUES ('Name of Slack Channel for Failure Notifications', 'SlackFailChannel', case when @Environment in ('Production','Processing') then '#prod_bot' else null end)

  END

  IF NOT EXISTS (SELECT 1 FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SlackURL')
  BEGIN

  	INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription, SettingName, SettingValue)
	VALUES ('Slack Webhook URL', 'SlackURL', 'https://hooks.slack.com/services/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')
	--https://hooks.slack.com/services/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 old value
	

  END

  IF NOT EXISTS (SELECT 1 FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SlackIcon')
  BEGIN

    INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription, SettingName, SettingValue)
	VALUES ('Slack Icon Image', 'SlackIcon', ':autobot:')

  END

--Add fail step to all jobs
CREATE TABLE #temp(
	job_id VARCHAR(50)
)

DECLARE @JobID VARCHAR(50)
DECLARE @MaxJobStep INT
DECLARE Cur_Jobs CURSOR FOR SELECT * FROM #temp
DECLARE @StepID VARCHAR(50)
DECLARE @Count int 
DECLARE @SuccessStepID int
DECLARE @FailStepID int
DECLARE @CurrentStepName varchar (500)

INSERT INTO #temp (job_id)
SELECT job_id FROM msdb.dbo.sysjobs

OPEN Cur_Jobs

FETCH NEXT FROM Cur_Jobs INTO @jobID

WHILE @@FETCH_STATUS = 0

BEGIN
	--Preserve step structures for repairing on_success/on_failure links 
    SELECT * INTO #job_steps from msdb.dbo.sysjobsteps where job_id = @JobID
	--Check to see if fail notification step exists, if so drop it
	IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobsteps WHERE step_name = 'Failure Notification' and job_id = @JobID)
		BEGIN
			SET @StepID = (SELECT step_id FROM msdb.dbo.sysjobsteps WHERE job_id =  @JobID and step_name = 'Failure Notification')
			EXEC msdb.dbo.sp_delete_jobstep @job_id = @JobID, @step_id = @StepID
		END
	--Set step ID
	SET @MaxJobStep = (SELECT MAX(step_id) FROM msdb.dbo.sysjobsteps WHERE job_id = @JobID) + 1
	--Add job step
	EXEC msdb.dbo.sp_add_jobstep @job_id = @jobID, @step_id = @MaxJobStep, @step_name = N'Failure Notification', @subsystem = N'TSQL', 
	@command = N'EXEC TPS_DBA.dbo.uspSendFailNotification',
	@cmdexec_success_code = 0,
	@on_success_action = 2,
	@on_fail_action = 2


	--repair step links, set all steps to go to failure notification if needed
	SET @Count = 1
	WHILE (@Count <= @MaxJobStep)
		BEGIN
			--Initiailize current step
			SET @CurrentStepName = (select step_name from msdb.dbo.sysjobsteps where step_id = @count and job_id = @JobID)
			--Reconstruct success action if not set to go to next step
			IF ((SELECT on_success_action FROM #job_steps WHERE step_name = @CurrentStepName) = 4)
				BEGIN
					SET @SuccessStepID = (select step_id from msdb.dbo.sysjobsteps where step_name = 
											(select step_name from #job_steps where step_id = 
												(select on_success_step_id from #job_steps where step_name = @CurrentStepName) and job_id = @JobID
											) and job_id = @JobID
										)
					EXEC msdb.dbo.sp_update_jobstep @job_id = @JobID, @step_id = @Count, @on_success_action = 4, 
						 @on_success_step_id = @SuccessStepID			 
				END
			--Reconstruct fail action if not set to quit reporting failure
			IF ((SELECT on_fail_action FROM #job_steps WHERE step_name = @CurrentStepName) = 4)
				BEGIN
					SET @FailStepID = (select step_id from msdb.dbo.sysjobsteps where step_name = 
										 (select step_name from #job_steps where step_id = 
											(select on_fail_step_id from #job_steps where step_name = @CurrentStepName) and job_id = @JobID
										 ) and job_id = @JobID
									  )
					EXEC msdb.dbo.sp_update_jobstep @job_id = @JobID, @step_id = @Count, @on_fail_action = 4, 
						 @on_fail_step_id = @FailStepID
				END
			--Set fail action to go to failure notification if configured to quit reporting failure
			IF ((SELECT on_fail_action FROM msdb.dbo.sysjobsteps WHERE job_id = @JobID and step_id = @count and step_name <> 'Failure Notification') = 2)
				BEGIN
					SET @FailStepID = (select step_id from msdb.dbo.sysjobsteps where job_id = @JobID and step_name = 'Failure Notification')
					EXEC msdb.dbo.sp_update_jobstep @job_id = @JobID, @step_id = @Count, @on_fail_action = 4, @on_fail_step_id = @FailStepID
				END
			--Advance to the next step in the job
			SET @count = @Count + 1
		END
		DROP TABLE #job_steps	
	
	FETCH NEXT FROM Cur_Jobs INTO @jobID
	END

CLOSE Cur_Jobs
DEALLOCATE Cur_Jobs
DROP TABLE #temp


END

GO


