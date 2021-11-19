/***************************************************************************
This script will modify the existing auto shutdown job schedule
- for any weekly and daily job, it will remove all friday schedule. 
- start and end time will remains unchanged
- if the schedule is disabled, it will also remain disabled.


******************************************************************************/
DECLARE @autoshutdownjobname VARCHAR(1000), @schedulename VARCHAR(1000), @patchingschedulename VARCHAR(1000);
DECLARE @schedule_id int, @old_enabled int, @old_starttime int, @old_endtime int, @old_freq_type int, @old_freq_interval int;


-- New Schedule Name
SET @patchingschedulename = 'Shutdown Schedule with Friday Patching Gap'; 

-- Get the current schdule(s) for the Autoshutdown job 
SELECT 
		[sJOB].name AS JobName
		, [sSCH].[name] AS [ScheduleName]
		, [sSCH].schedule_id
		, [sSCH].enabled 
		,freq_type   
		,freq_interval  
		,active_start_time
		,active_end_time  
	INTO tmpAutoShutdownSchedule
	FROM
		[msdb].[dbo].[sysjobs] AS [sJOB] 
		LEFT JOIN [msdb].[dbo].[sysjobschedules] AS [sJOBSCH]
			ON [sJOB].[job_id] = [sJOBSCH].[job_id]
		LEFT JOIN [msdb].[dbo].[sysschedules] AS [sSCH]
			ON [sJOBSCH].[schedule_id] = [sSCH].[schedule_id] 
	WHERE [sJOB].[name]  like '%AutoShutdown%'
		AND [freq_type] IN (4,8) -- Daily and Weekly

-- Loop through the existing schedule(s)
DECLARE MYCURSOR CURSOR FOR
    SELECT 
		JobName
		, [ScheduleName]
		,schedule_id
		,enabled 
		,freq_type   
		,freq_interval  
		,active_start_time
		,active_end_time  
	FROM tmpAutoShutdownSchedule
		ORDER BY JobName ;
 
OPEN MYCURSOR
FETCH NEXT FROM MYCURSOR INTO @autoshutdownjobname, @schedulename,@schedule_id, @old_enabled, @old_freq_type, @old_freq_interval, @old_starttime, @old_endtime
 
WHILE @@FETCH_STATUS = 0
BEGIN 
   -- Debug
   --SELECT @autoshutdownjobname, @schedulename,@schedule_id, @old_enabled, @old_freq_type, @old_freq_interval, @old_starttime, @old_endtime

   -- Set the new schedule name (also retain the old schedule name for reference)
	IF @schedulename = @patchingschedulename
	BEGIN
		SET @schedulename = @patchingschedulename
	END 
	ELSE
	BEGIN
		SET @schedulename = @patchingschedulename + ' (modified from ' + @schedulename + ')'
	END



   -- if this is a weekly schedule containing Friday 
   IF @old_freq_type = 8 AND @old_freq_interval & 32 = 32
   BEGIN		
	   -- remove Friday schedule
	   SET @old_freq_interval = @old_freq_interval - 32

	   EXEC msdb.dbo.sp_add_jobschedule  @job_name = @autoshutdownjobname
		,@name =  @schedulename
		,@enabled = @old_enabled
		,@freq_type  = 8
		,@freq_interval = @old_freq_interval 
		,@freq_subday_type = 8
		,@freq_subday_interval = 1
		,@freq_relative_interval = 0 
		,@freq_recurrence_factor = 1
		,@active_start_date = 20200515
		,@active_end_date = 99991231 
		,@active_start_time = @old_starttime
		,@active_end_time = @old_endtime 

	   -- drop existing schedule
	   EXEC msdb.dbo.sp_detach_schedule @job_name = @autoshutdownjobname
		, @schedule_id = @schedule_id
		, @delete_unused_schedule = 1 
   END

   -- If it is daily schedule
   IF @old_freq_type = 4  
   BEGIN
	   -- create new schedule with the same start and end time, but skipping Friday and Saturday shutdown
	   EXEC msdb.dbo.sp_add_jobschedule  @job_name = @autoshutdownjobname
		,@name =  @schedulename
		,@enabled = @old_enabled
		,@freq_type  = 8
		,@freq_interval = 95
		,@freq_subday_type = 8
		,@freq_subday_interval = 1
		,@freq_relative_interval = 0 
		,@freq_recurrence_factor = 1
		,@active_start_date = 20200515
		,@active_end_date = 99991231 
		,@active_start_time = @old_starttime
		,@active_end_time = @old_endtime 

	   -- drop existing schedule
	   EXEC msdb.dbo.sp_detach_schedule @job_name = @autoshutdownjobname
		, @schedule_id = @schedule_id
		, @delete_unused_schedule = 1 
	END

   FETCH NEXT FROM MYCURSOR INTO @autoshutdownjobname, @schedulename,@schedule_id, @old_enabled, @old_freq_type, @old_freq_interval, @old_starttime, @old_endtime
END
CLOSE MYCURSOR
DEALLOCATE MYCURSOR
GO

-- Cleanup
DROP TABLE tmpAutoShutdownSchedule