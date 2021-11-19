USE [TPS_DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspCreateJob]    Script Date: 2/21/2019 3:04:16 PM ******/
DROP PROCEDURE if exists [dbo].[uspCreateJob]
GO

/****** Object:  StoredProcedure [dbo].[uspCreateJob]    Script Date: 2/21/2019 3:04:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspCreateJob]
/*******************************************************************************************
Name:               uspCreateJob
Purpose:            Creates a job that executes a specified list of scripts. 
Inputs:             None
Author:             Aidan Fennessy
Created:            8th Feb 2018
History:            Date                Name                Comment
                    8th Feb 2018		Aidan Fennessy		Initial Creation

Copyright:
RunTime:            00:00:00 (HH:MM:SS)

Execution:          EXEC TPS_DBA.dbo.uspCreateJob @JobListString = 'CHAIN: SHS Retail'

NOTES:
					When passing function calls that use strings as input parameters use Ctrl-F to Find and Replace instances of ' with '' 
					and then change the first and last '' of the @JobListString string to ' to allow for execution of strings. 
					
					i.e. 
					FROM:
					EXEC TPS_DBA.dbo.uspCreateJob @JobListString = 'print'test1'| print'test2'| print'test3''
					TO:
					EXEC TPS_DBA.dbo.uspCreateJob @JobListString = 'print''test1''| print''test2''| print''test3'''


*******************************************************************************************/
(	@JobListString VARCHAR(MAX))

AS
BEGIN
	SET NOCOUNT ON 

	DECLARE @operatorid nvarchar(100) = (SELECT [name] FROM msdb.dbo.sysoperators WHERE name = tps_dba.dbo.udfGetServerSetting('SQLServerAgentOperator'));
	DECLARE @MaxJobStep INT
	
	--Add step to all jobs
		IF OBJECT_ID('tempdb.dbo.#StepList', 'U') IS NOT NULL
			DROP TABLE #StepList; 
		CREATE TABLE #StepList(StepList NVARCHAR(MAX))
	
		INSERT INTO #StepList (StepList)		
		(select * from [TPS_DBA].[dbo].[udfSplitstring](@JobListString, '|'))

	IF  EXISTS (SELECT job_id FROM msdb..sysjobs WHERE name = N'AutoJob')
	BEGIN
		EXEC msdb.dbo.sp_delete_job @job_name=N'AutoJob', @delete_unused_schedule=1
	END

	DECLARE @jobId BINARY(16)
	EXEC  msdb.dbo.sp_add_job @job_name=N'AutoJob', 
			@enabled=1, 
			@start_step_id=1, 
			@notify_level_eventlog=0, 
			@notify_level_email=2, 
			@notify_level_page=2, 
			@delete_level=1, --automatically deletes job upon successful completion. 0 = Never, 1 = When the job succeeds, 2 = When the job fails, 3 = Whenever the job completes (regardless of the job outcome)
			@category_name=N'[Uncategorized (Local)]', 
			@owner_login_name=N'sa', 
			@notify_email_operator_name=@operatorid, @job_id = @jobId OUTPUT
	--select @jobId
	EXEC msdb.dbo.sp_add_jobserver @job_name=N'AutoJob', @server_name = @@SERVERNAME

	DECLARE @StepScript varchar(max) = ''
	DECLARE @StepID int = 1
	--Begin loop
	DECLARE Cur_Jobs CURSOR Local Fast_Forward FOR SELECT StepList FROM #StepList
	OPEN Cur_Jobs
	
	FETCH NEXT FROM Cur_Jobs INTO @StepScript
	
	WHILE @@FETCH_STATUS = 0
	
	BEGIN
		EXEC msdb.dbo.sp_add_jobstep @job_id = @jobID, @step_id = @StepID, @step_name = @StepID, @subsystem = N'TSQL', 
		@command = @StepScript,
		@cmdexec_success_code = 0,
		@on_success_action = 3, --Set to Go to next step
		@on_fail_action = 2 --Quit with failure

		SET @StepID = @StepID + 1
	
		FETCH NEXT FROM Cur_Jobs INTO @StepScript
	END
	
	CLOSE Cur_Jobs
	DEALLOCATE Cur_Jobs

	--Set last step to Quit Reporting Success.
	SET @MaxJobStep = (SELECT MAX(step_id) FROM msdb.dbo.sysjobsteps WHERE job_id = @JobID)
	EXEC msdb.dbo.sp_update_jobstep @job_id = @JobID, @step_id = @MaxJobStep, @on_success_action = 1


END
GO


