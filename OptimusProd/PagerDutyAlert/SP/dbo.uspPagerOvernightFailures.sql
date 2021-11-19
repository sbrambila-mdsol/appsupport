USE [TPS_DBA]
GO
IF OBJECT_ID('dbo.uspPagerOvernightFailures') IS NOT NULL 
    BEGIN 
        DROP PROCEDURE dbo.uspPagerOvernightFailures 
    END
GO
/****** Object:  StoredProcedure [dbo].[uspPagerOvernightFailures]    Script Date: 10/9/2018 9:32:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspPagerOvernightFailures]
/*******************************************************************************************
Name:               uspPagerOvernightFailures
Purpose:            Create a PagerDuty incident for each job unique overnight job failure.
Inputs:             None
Author:             Aidan Fennessy
Created:            2nd May 2019
History:            Date                Name                Comment
                    2nd May 2019		Aidan Fennessy		Initial Creation

Copyright:
RunTime:            00:00:00 (HH:MM:SS)

Execution:          EXEC TPS_DBA.dbo.uspPagerOvernightFailures 
NOTES:


 USEFUL SELECTS:

					
*******************************************************************************************/

AS
BEGIN
	SET NOCOUNT ON 
	DECLARE @server VARCHAR(500)
	DECLARE @jobname VARCHAR(500)
	DECLARE @failuretime VARCHAR(500)
	DECLARE @body VARCHAR(500)
	DECLARE @subject VARCHAR(500)

	--DROP TABLE IF EXISTS #FAILEDOVERNIGHTJOBS
	
	IF OBJECT_ID('tempdb.dbo.#FAILEDOVERNIGHTJOBS', 'U') IS NOT NULL
		DROP TABLE #FAILEDOVERNIGHTJOBS; 
	SELECT ROW_NUMBER() over (ORDER BY sh.run_time asc) AS 'Row_Number', sh.server , SJ.name, 
	DATEADD(ss, (( sh.run_duration / 10000 * 3600 + ( sh.run_duration / 100 )%100 * 60 + sh.run_duration%100 )), msdb.dbo.Agent_DATETIME(sh.run_date, sh.run_time)) AS FailedTime 
	INTO #FAILEDOVERNIGHTJOBS 
	FROM msdb.dbo.sysjobs sj
	JOIN msdb.dbo.sysjobhistory sh  ON sj.job_id = sh.job_id
	JOIN msdb.dbo.sysjobschedules a	ON A.job_id = SH.job_id		
	INNER JOIN msdb.dbo.sysschedules js
	ON a.schedule_id = js.schedule_id
	WHERE step_name = '(Job outcome)'
	AND DATEADD(ss, (( sh.run_duration / 10000 * 3600 + ( sh.run_duration / 100 )%100 * 60 + sh.run_duration%100 )), msdb.dbo.Agent_DATETIME(sh.run_date, sh.run_time))  
		>= cast(cast((cast(DATEADD(DD,-1,CONVERT(varchar(8), GETDATE(), 112)) as date)) as varchar) + ' 22:30:00.000' as datetime)
	AND run_status = 0							--ONLY GRAB FAILED JOBS
	AND sj.name not like '%util%' AND sj.name not like '%autoshutdown%' AND sj.name not like '%Backups%' AND sj.name not like '%CLEANUP%' 
	AND sj.name not like '%maintenance%' AND sj.name not like '%OVERNIGHT JOB FAILURE CHECK%' 	--IGNORE NON-CRITICAL JOBS
	AND JS.enabled = 1 AND SJ.enabled = 1		--ONLY FOR JOBS THAT ARE SCHEDULED TO RUN (SO ONLY ONE INCIDENT TICKET PER CHAIN FAILURE)
	--SELECT * FROM #FAILEDOVERNIGHTJOBS
	
	IF (SELECT COUNT(*) FROM #FAILEDOVERNIGHTJOBS) > 0 
		BEGIN

				DECLARE @NextEmail VARCHAR(1000) 
				--Begin loop for sending one email about each unique incident (job failure)
				DECLARE Cur_Emails CURSOR FOR (SELECT [Row_Number] FROM #FAILEDOVERNIGHTJOBS)
				OPEN Cur_Emails
			
				FETCH NEXT FROM Cur_Emails INTO @NextEmail
			
				WHILE @@FETCH_STATUS = 0
			
				BEGIN
							
					SELECT TOP 1
					@server = ISNULL(server, ''),
					@jobname = ISNULL(name, ''),
					@failuretime	= ISNULL(FailedTime, '')
					FROM #FAILEDOVERNIGHTJOBS
					WHERE [Row_Number] = @NextEmail
					SET @subject = @jobname + ' FAILED ON ' + @server + ' at ' + @failuretime
					SET @body = @jobname + ' FAILED ON ' + @server + ' at ' + @failuretime
										
					EXEC msdb.dbo.sp_send_dbmail 
					  @recipients = 'shyft-application-services@mdsol.pagerduty.com'
					, @body = @body
					, @subject = @subject
								
				FETCH NEXT FROM Cur_Emails INTO @NextEmail
			
				END
			
			CLOSE Cur_Emails
			DEALLOCATE Cur_Emails
		END

END
	
GO
