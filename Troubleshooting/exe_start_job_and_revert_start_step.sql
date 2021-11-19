USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'',	--name of sub-job
		@start_step_id = 1					--change sub-job to start at desired step
GO

exec sp_start_job 
		@job_name = ''		--name of master/chain-job
		,@step_name = ''	--start master/chain job to start at desired step

WAITFOR DELAY '00:00:10'

USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'',	--name of sub-job 
		@start_step_id = 1					--revert sub-job to start at desired step
GO
 