USE [msdb]
GO

--update <customer> to customer name i.e. tgtx
--update <PRDServer> to production server i.e. PRDTGTX10DB1
--update <Password> to password i.e. 123456!
--create new schedule to the job
--add email failure notification to the job


/****** Object:  Job [SFTP Checker]    Script Date: 4/20/2021 2:01:21 PM ******/


/****** Object:  Job [SFTP Checker]    Script Date: 4/20/2021 2:01:21 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 4/20/2021 2:01:21 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SFTP Checker', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [SFTP Checker]    Script Date: 4/20/2021 2:01:21 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'SFTP Checker', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=4, 
		@on_fail_step_id=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
DECLARE @vchSQL VARCHAR(MAX)
DECLARE @result TABLE (Line NVARCHAR(512))

SET	@vchSQL = ''EXEC xp_cmdshell ''''C:\"Program Files (x86)"\WinSCP\winscp.com /command "open sftp://strata:<Password>@<customer>-sftp.shyftanalytics.com:2222/ -hostkey=*"  "exit"'''''' 

INSERT INTO @result
EXEC (@vchSQL)

SELECT * FROM @result	
	 

IF NOT EXISTS (SELECT * FROM @result WHERE Line LIKE ''%Session started%'')
	
BEGIN  


   EXEC TPS_DBA.dbo.uspSlackErrorMessage @message = ''URGENT ALERT: Failure to connect to <customer> SFTP (<customer>-sftp.shyftanalytics.com). Please manually login with FileZilla and confirm if the <customer> SFTP is down. If the password is changed recently, please update the password in the SFTP Checker job on <PRDServer>  '', @NOTIFY = ''<!here>''

END 
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Slack Fail Message]    Script Date: 4/20/2021 2:01:21 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Slack Fail Message', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC TPS_DBA.dbo.uspSlackSFTPErrorMessage @message = ''If you see this message, check to make sure the SFTP Checker job is working on <PRDServer>'', @NOTIFY = ''<!here>''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


