USE [TPS_DBA]
GO

DROP PROCEDURE IF EXISTS dbo.[uspCheckIfJobStarted]
GO

/****** Object:  StoredProcedure [dbo].[uspCheckIfJobStarted]    Script Date: 4/3/2020 11:44:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspCheckIfJobStarted]
/*******************************************************************************************
Name:               uspCheckIfJobStarted 
Purpose:            Will fail if a job that was scheduled to kick off did not start at its scheduled time.
Inputs:             None
Author:             Aidan Fennessy
Created:            18th Sep 2018
History:            Date                Name                Comment
                    18th Oct 2018       Aidan Fennessy      Initial Creation

Copyright:
RunTime:            00:00:30 (HH:MM:SS)

Execution:          EXEC TPS_DBA.dbo.uspCheckIfJobStarted
					
					Deploy this procedure on your processing server.
					If the below query returns any jobs that did not kick off as scheduled the procedure will raise an error and send a notification. 

*******************************************************************************************/
AS

BEGIN
--Find jobs that were scheduled to run today but for which the scheduled time has past.
	DROP TABLE IF EXISTS  #UnranJobs; 
	SELECT  sj.name
	INTO    #UnranJobs
	FROM    msdb.dbo.sysjobs sj
	        INNER JOIN msdb.dbo.sysjobschedules sjs
	            ON sj.job_id = sjs.job_id
	            AND sjs.next_run_date = TRY_CONVERT(INT, CONVERT(varchar(8), GETDATE(), 112)) 
	            AND sjs.next_run_time <= TRY_CONVERT(INT, replace(Convert (varchar(8),GetDate(), 108),':',''))  
	        INNER JOIN msdb.dbo.sysschedules ss
	            ON sjs.schedule_id = ss.schedule_id
	            AND ss.enabled = 1
	WHERE   NOT EXISTS  
	--Check that those jobs are not today's job history 
	                (
	                    SELECT  1
	                    FROM    msdb.dbo.sysjobhistory sh  
	                    WHERE   sh.job_id = sj.job_id
	                    AND     sh.step_name = '(Job outcome)'
	                    AND     sh.run_date = TRY_CONVERT(INT, CONVERT(varchar(8), GETDATE(), 112)) 
	                    AND     sh.run_time <= TRY_CONVERT(INT, replace(Convert (varchar(8),GetDate(), 108),':',''))
	                )
	--Check that those jobs are not currently running
	AND     NOT EXISTS 
	                (
	                    SELECT  1
	                    FROM    msdb.dbo.sysjobactivity sja
	                    WHERE   sja.job_id = sj.job_id
	                    AND     CONVERT(DATE,sja.start_execution_date ) = CONVERT(DATE,GETDATE ())
	                    AND     sja.stop_execution_date IS NULL
	                )



IF (select count(*) AS NumberOfUnranJobs from #UnranJobs) > 0
--If there are any jobs that were scheduled to kick off but did not and those jobs did not run earlier today or are not currently running then raise an alert.
--Declare the name of the most recent job that did not kick off.
BEGIN
	--String_agg only works in SQL 2017
	--DECLARE @JobThatDidNotKick varchar(max) = (SELECT STRING_AGG(name, ', ') AS JOB_STRING FROM #UnranJobs)
	--print @JobThatDidNotKick

	DECLARE @CSVString varchar(max) = ''
	SELECT @CSVString = @CSVString + name + ', ' from #UnranJobs

	DROP TABLE IF EXISTS #tblUnranJobs; 
	CREATE TABLE #tblUnranJobs (Jobname varchar(max))
	Insert into #tblUnranJobs (Jobname)
	select (@CSVString)

	DECLARE @srvr NVARCHAR(128) = (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting where settingdescription like '%processing%server%');
	DECLARE @JobThatDidNotKick varchar(1000) = (SELECT * FROM #tblUnranJobs)
	DECLARE @ErrorMessage varchar(500) = 'The job(s), ' + @JobThatDidNotKick + 'did not start as scheduled on ' + @srvr + '.'	

	--Insert message into table to allow production job to grab it.
	
	delete from TPS_DBA.dbo.tblSlackPassThroughMessages
	Insert into TPS_DBA.dbo.tblSlackPassThroughMessages (Message)
	select (@ErrorMessage)
	--SELECT * FROM TPS_DBA.dbo.tblSlackPassThroughMessages
		
	RAISERROR (@ErrorMessage, 16, 1)

END

IF (select count(*) AS NumberOfUnranJobs from #UnranJobs) = 0

	BEGIN 
		PRINT 'Job(s) started as scheduled'

		delete from TPS_DBA.dbo.tblSlackPassThroughMessages
		Insert into TPS_DBA.dbo.tblSlackPassThroughMessages (Message)
		SELECT 'Job(s) started as scheduled'
	END

END



GO


