USE [TPS_DBA]
GO
IF OBJECT_ID('dbo.uspSendFailNotification') IS NOT NULL 
    BEGIN 
        DROP PROCEDURE dbo.uspSendFailNotification 
    END
GO
/****** Object:  StoredProcedure [dbo].[uspSendFailNotification]    Script Date: 10/9/2018 9:32:16 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspSendFailNotification]
/*******************************************************************************************
Name:               uspSendFailNotification
Purpose:            Sends a notification to the failure channel for a given environment.
Inputs:             None
Author:             Aidan Fennessy
Created:            2nd May 2019
History:            Date                Name                Comment
                    2nd May 2019		Aidan Fennessy		Initial Creation

Copyright:
RunTime:            00:00:00 (HH:MM:SS)

Execution:          EXEC TPS_DBA.dbo.uspSendFailNotification 
NOTES:


 USEFUL SELECTS:

					
*******************************************************************************************/

AS
BEGIN

		DECLARE @jobname VARCHAR(100)
		DECLARE @STEPNAME VARCHAR(100) 
		DECLARE @server VARCHAR(100) = @@servername 
		DECLARE @failuretime VARCHAR(100) = getdate()
		DECLARE @PagerDutyMESSAGE VARCHAR(100)
		DECLARE @MESSAGE VARCHAR(1000) 
		
		IF OBJECT_ID('tempdb.dbo.#JobList', 'U') IS NOT NULL
			DROP TABLE #JobList; 
		CREATE TABLE #JobList(JobName VARCHAR(500), JobStep VARCHAR(500))
		INSERT INTO #JobList (JobName, JobStep)	
		SELECT TOP 1 je.NAME, 
						 je.step_name
			FROM   (SELECT jh.instance_id, 
						   j.NAME, 
						   js.step_name, 
						   jh.sql_severity, 
						   jh.message, 
						   jh.run_date, 
						   jh.run_time, 
						   jh.run_duration, 
						   js.step_id, 
						   msdb.dbo.Agent_datetime(jh.run_date, jh.run_time) AS StartTime, 
						   Dateadd(ss, ((jh.run_duration/10000*3600 + (jh.run_duration/100)%100*60 + jh.run_duration%100)), msdb.dbo.Agent_datetime(jh.run_date, 
														jh.run_time)) 
																			 AS 
						   CompletionTime 
					FROM   msdb.dbo.sysjobs AS j 
						   INNER JOIN msdb.dbo.sysjobsteps AS js 
								   ON js.job_id = j.job_id 
						   INNER JOIN msdb.dbo.sysjobhistory AS jh 
								   ON jh.job_id = j.job_id 
									  AND jh.step_name = js.step_name 
					WHERE  jh.run_status = 0 
						   --AND jh.sql_severity > 9 
						   AND js.step_name <> 'Failure Notification'
							OR ( jh.message LIKE '%failed%' 
								 AND (js.step_name LIKE '%subplan%' 
								 or  js.step_name LIKE '%SSIS%')
								 AND js.step_name <> 'Failure Notification' ))je 
			ORDER  BY je.CompletionTime
					  DESC, 
					  je.step_id DESC

			SET @jobname =  (SELECT JobName FROM #JobList)
			SET @STEPNAME =  (SELECT JobStep FROM #JobList)
			SET @PagerDutyMESSAGE = @jobname + ' FAILED ON ' + @server + ' at ' + @failuretime
			SET @MESSAGE = '<!here> Failure on ' + CHAR(10) + 'Job Name: '  + @jobname + CHAR(10) + 'Job Step: ' + @STEPNAME
		
		--Update TPS_DBA.dbo.ErrorResults  with latest error info
		EXEC TPS_DBA.dbo.uspFindLatestErrorInfo_MA

		--Add error information to slack message contents
		SELECT @MESSAGE = '<!here> Failure on ' + CHAR(10) + '*Job Name:* '  + @jobname + CHAR(10) + '*Job Step:* ' + @STEPNAME
		 + CHAR(10) + '*DatabaseName:* ' + ISNULL(DatabaseName, 'N/a')
		  + CHAR(10) + '*TaskQueueError:* ' + ISNULL(LEFT(TaskQueueError,IIF(CHARINDEX('uspExecuteTaskManager', TaskQueueError)=0, 250, CHARINDEX('uspExecuteTaskManager', TaskQueueError)+21) ), 'N/a')
		   + CHAR(10) + '*ScenarioTypeID:* ' + ISNULL(ScenarioTypeID, 'N/a') + ' TaskQueueID: ' + ISNULL(TaskQueueID, 'N/a')
			 + CHAR(10) + '*ImportTableName:* ' + ISNULL(ImportTableName, 'N/a')
			  + CHAR(10) + '*ImportedFileName:* ' + ISNULL(ImportedFileName, 'N/a')
			   + CHAR(10) + '*ImportErrorMessage:* ' + ISNULL(ImportErrorMessage, 'N/a')
			    + CHAR(10) + '*DataFeedLocation:* ' + ISNULL(DataFeedLocation, 'N/a')
				 + CHAR(10)
		FROM TPS_DBA.dbo.ErrorResults 
		WHERE ErrorId = (SELECT max(ErrorId) FROM TPS_DBA.dbo.ErrorResults)
				
		--REPLACE " WITH ' so that powershell can handle the message
		SET @MESSAGE = ISNULL(replace(@MESSAGE, '"', ''''), 'Error sending message on PRDSHFUPK1 about job failure, please investigate')

		--SEND MESSAGE TO FAILURE CHANNEL 
		EXEC TPS_DBA.dbo.uspSlackErrorMessage @MESSAGE = @MESSAGE

		--removed pager duty api FOR TOKENIZATION SERVER


END	