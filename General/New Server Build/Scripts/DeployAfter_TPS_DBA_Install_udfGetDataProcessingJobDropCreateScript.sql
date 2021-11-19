USE TPS_DBA
GO
IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.Routines WHERE Routine_Name='udfGetDataProcessingJobDropCreateScript' AND Routine_Schema='dbo' AND ROUTINE_TYPE='FUNCTION')
BEGIN
       DROP FUNCTION dbo.udfGetDataProcessingJobDropCreateScript    
END

GO

CREATE FUNCTION dbo.udfGetDataProcessingJobDropCreateScript    
/*********************************************************************************************************************************
Purpose:   Returns a SQL script for dropping/creating jobs that conform to the data processing job infrastructure 
Inputs:		
Author:		Crichton
Created:	9/17/2018
Changed:

Sample Execution: 

						PRINT dbo.udfGetDataProcessingJobDropCreateScript(N'Daily: Update DataDate & Create Directory',0, 'Owner')
						PRINT dbo.udfGetDataProcessingJobDropCreateScript(N'_MASTER: MONTHLY CDP CHAIN',0, 'owner')
						PRINT dbo.udfGetDataProcessingJobDropCreateScript(N'DataRun Adhoc 1: Adhoc Data Load',0, 'owner')
*********************************************************************************************************************************/
(

	@JobName				NVARCHAR(128)
	,@DeleteUnusedSchedule	BIT
	,@JobOwner				VARCHAR(128)
)

	RETURNS NVARCHAR(4000)
AS 

BEGIN

	DECLARE @ReturnVal			NVARCHAR(4000)
			,@AttachSchedule	NVARCHAR(4000) = ''
			,@intCounter		INT = 1
			,@ScheduleID		VARCHAR(10)
			,@JobNameInput		NVARCHAR(128) = '$(ESCAPE_SQUOTE(JOBNAME))'

	-----	If SQL Version is less than 13.x (earlier than SQL Server 2016) use explicit JobName
	-----	Otherwise use the job token
	IF	LEFT((CAST(SERVERPROPERTY('PRODUCTVERSION') AS VARCHAR)),2) < 13
	BEGIN
		SET	@JobNameInput = @JobName
	END

	DECLARE @tblSchedules	TABLE
		(
			ID INT IDENTITY(1,1)
			,ScheduleID INT
		)
	
	IF @DeleteUnusedSchedule = 0
	BEGIN
		
		INSERT INTO		@tblSchedules
			(
				ScheduleID
			)
		SELECT	ScheduleId = schedule_id
		FROM	msdb.dbo.sysjobschedules S
				INNER JOIN	msdb.dbo.sysjobs J	ON
						S.job_id = J.job_id
		WHERE 	J.name = @JobName

		WHILE @intCounter <= (SELECT	MAX(ID) FROM @tblSchedules)
		BEGIN
			
			SELECT	@ScheduleID = ScheduleID
			FROM	@tblSchedules
			WHERE 	ID = @intCounter

			SELECT	@AttachSchedule = @AttachSchedule + '

			EXEC	msdb.dbo.sp_attach_schedule
					@job_name = '''+@JobName+'''
					,@schedule_id = '''+@ScheduleID+'''
					
					
					'

			SET @intCounter = @intCounter + 1

		END
	END

	SET @ReturnVal = '

		USE [msdb]
		

		IF (SELECT 1 FROM msdb..sysjobs WHERE name = N''[JobName]'') IS NOT NULL
		BEGIN 
		   EXEC msdb.dbo.sp_delete_job @job_name=N''[JobName]'',@delete_history = 0, @delete_unused_schedule='+CAST(@DeleteUnusedSchedule AS VARCHAR)+'
		END

		

		BEGIN TRANSACTION
		DECLARE @ReturnCode INT
		SELECT @ReturnCode = 0
		IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N''[Uncategorized (Local)]'' AND category_class=1)
		BEGIN
		EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N''JOB'', @type=N''LOCAL'', @name=N''[Uncategorized (Local)]''
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

		END

		DECLARE @jobId BINARY(16)
		EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name= N''[JobName]'', 
				@enabled=1, 
				@notify_level_eventlog=0, 
				@notify_level_email=0, 
				@notify_level_netsend=0, 
				@notify_level_page=0, 
				@delete_level=0, 
				@description=N''Default description '', 
				@category_name=N''[Uncategorized (Local)]'', 
				@owner_login_name=N'''+@JobOwner+''', @job_id = @jobId OUTPUT
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		/****** Object:  Step [test]    Script Date: 9/17/2018 7:46:38 AM ******/
		EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N''Default Step 1'', 
				@step_id=1, 
				@cmdexec_success_code=0, 
				@on_success_action=1, 
				@on_success_step_id=0, 
				@on_fail_action=2, 
				@on_fail_step_id=0, 
				@retry_attempts=0, 
				@retry_interval=0, 
				@os_run_priority=0, @subsystem=N''TSQL'', 
				@command=N''

			EXEC TPS_DBA.dbo.uspJobRunDataProcessingJob
						@JobName = ''''' + @JobNameInput + '''''
						'', 
				@database_name=N''master'', 
				@flags=0
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N''(local)''
		IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
		COMMIT TRANSACTION
		GOTO EndSave
		QuitWithRollback:
			IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
		EndSave:
		
		

		'
	SET @ReturnVal = REPLACE(@ReturnVal,N'[JobName]',@JobName) + @AttachSchedule

	RETURN @ReturnVal
END