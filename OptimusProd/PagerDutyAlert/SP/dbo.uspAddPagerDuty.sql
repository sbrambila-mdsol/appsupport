USE [TPS_DBA]
GO
IF OBJECT_ID('dbo.uspAddPagerDuty') IS NOT NULL 
    BEGIN 
        DROP PROCEDURE dbo.uspAddPagerDuty 
    END
GO
/****** Object:  StoredProcedure [dbo].[uspAddPagerDuty]    Script Date: 10/9/2018 9:32:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspAddPagerDuty]
/*******************************************************************************************
Name:               uspAddPagerDuty
Purpose:            Add pager duty operator to all off hours jobs.
Inputs:             None
Author:             Aidan Fennessy
Created:            18th Oct 2018
History:            Date                Name                Comment
                    18th Oct 2018       Aidan Fennessy      Initial Creation

Copyright:
RunTime:            00:00:30 (HH:MM:SS)

Execution:          EXEC TPS_DBA.dbo.uspAddPagerDuty 
NOTES:

	
 USEFUL SELECTS:
					
*******************************************************************************************/
(	@JobListCSVString VARCHAR(MAX) = NULL	)

AS
BEGIN
	SET NOCOUNT ON 
	--declare @JobListCSVString VARCHAR(MAX) = NULL
	DECLARE @JobID VARCHAR(500)
	
	--Add step to all jobs
		IF OBJECT_ID('tempdb.dbo.#JobList', 'U') IS NOT NULL
			DROP TABLE #JobList; 
		CREATE TABLE #JobList(job_id VARCHAR(500))
	
			INSERT INTO #JobList (job_id)		
			select A.job_id FROM msdb.dbo.sysjobschedules a
			join msdb.dbo.sysjobs b ON b.job_id = a.job_id
			INNER JOIN msdb.dbo.sysschedules js
			ON a.schedule_id = js.schedule_id
			where js.enabled = 1
			AND b.enabled = 1
			AND ((a.next_run_time <= 90000 AND a.next_run_time >= 70000) OR (
			a.next_run_time <= 223000 AND a.next_run_time >= 190000))  --60500)  --70000 
			AND b.name not like '%util%' AND b.name not like '%autoshutdown%'
			AND b.name not like '%Backups%' AND b.name not like '%DataDate%'
			AND b.name not like '%CLEANUP%' AND b.name not like '%maintenance%'
			AND b.name not like '%OVERNIGHT JOB FAILURE CHECK%' 
	--Raise Error if no jobs were found to add notifications to
	--IF NOT EXISTS (SELECT 1 FROM #JobList)
	--	BEGIN
	--		RAISERROR ('No jobs were found to add notifications to', 16, 1)
	--	END
	
	--Begin loop
	DECLARE Cur_Jobs CURSOR Local Fast_Forward FOR SELECT * FROM #JobList
	OPEN Cur_Jobs
	
	FETCH NEXT FROM Cur_Jobs INTO @jobID
	
	WHILE @@FETCH_STATUS = 0
	
	BEGIN
	
        EXEC msdb.dbo.sp_update_job @job_id = @JobID, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@notify_email_operator_name = 'PagerDuty'
          	
		FETCH NEXT FROM Cur_Jobs INTO @jobID
	END
	
	CLOSE Cur_Jobs
	DEALLOCATE Cur_Jobs

END
GO
