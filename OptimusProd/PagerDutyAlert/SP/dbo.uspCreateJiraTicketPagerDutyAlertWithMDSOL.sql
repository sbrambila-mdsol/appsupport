USE [TPS_DBA]
GO

IF OBJECT_ID('dbo.uspCreateJiraTicketPagerDutyAlertMDSOL', 'P') IS NOT NULL
DROP PROCEDURE [dbo].[uspCreateJiraTicketPagerDutyAlertMDSOL]
GO

/****** Object:  StoredProcedure [dbo].[uspCreateJiraTicketPagerDutyAlertMDSOL]    Script Date: 6/29/2020 3:27:17 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspCreateJiraTicketPagerDutyAlertMDSOL]
/*******************************************************************************************
Name:               uspCreateJiraTicketPagerDutyAlertMDSOL
Purpose:            Creates Jira ticket and Pager duty alert for jobs invoked by a schedule.
Inputs:             None
Author:             Aidan Fennessy
Created:            2nd May 2019
History:            Date                Name                Comment
                    2nd May 2019        Aidan Fennessy      Initial Creation
					22nd June 2020		Todd Forman			Modify to new sproc with mdsol email and new sender
Copyright:
RunTime:            00:00:00 (HH:MM:SS)
Execution:          EXEC TPS_DBA.dbo.uspCreateJiraTicketPagerDutyAlertMDSOL 
NOTES:
 USEFUL SELECTS:
                    
*******************************************************************************************/
AS
BEGIN
SET NOCOUNT OFF
 
        DECLARE @jobname VARCHAR(100)
        DECLARE @STEPNAME VARCHAR(100) 
        DECLARE @server VARCHAR(100) = @@servername 
        DECLARE @failuretime VARCHAR(100) = getdate()
        DECLARE @PagerDutyMESSAGE VARCHAR(100)
        DECLARE @MESSAGE VARCHAR(1000) 
        DECLARE @PshellString VARCHAR(1000) 
        DECLARE @rc VARCHAR(1000) 
        DECLARE @doc varchar(max) = ''
        DECLARE @line varchar(255)
        
        WAITFOR DELAY '00:00:01' 
        
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
        
        --CREATE UNIQUE PAGER DUTY ALERT DURING PRODUCTION TEAM SHIFT HOURS
        IF 
       
         (@failuretime <= cast(cast((cast(getdate() as date)) as varchar) + ' 21:30:00.000' as datetime) AND @failuretime >= cast(cast((cast(getdate() as date)) as varchar) + ' 19:00:00.000' as datetime))
        --ENSURE THAT THIS FAILURE IS OCCURRING DURING THE OFF HOURS SHIFTS  
        AND DATEPART(DW, GETDATE()) NOT IN (1, 7) -- DO NOT SEND ALERTS ON WEEKENDS
        AND (@server LIKE 'PRO%' or @server like 'PRD%') --MAKE SURE THAT WE ARE RUNNING ON THE PROCESSING ENVIRONMENT 
        AND (SELECT TOP 1 message FROM msdb.dbo.sysjobs sj
            JOIN msdb.dbo.sysjobhistory sh  ON sj.job_id = sh.job_id
            WHERE step_name = '(Job outcome)'
            AND sJ.name = @jobname
            AND sj.name not like '%util%' AND sj.name not like '%autoshutdown%' AND sj.name not like '%Backups%' AND sj.name not like '%CLEANUP%' 
            AND sj.name not like '%maintenance%' AND sj.name not like '%OVERNIGHT JOB FAILURE CHECK%'   --IGNORE NON-CRITICAL JOBSs
            AND try_cast(try_cast(sh.run_date as varchar) as date) = cast(getdate() as date)
            ORDER BY msdb.dbo.Agent_datetime(sh.run_date, sh.run_time) DESC
            ) LIKE '%invoked by schedule%'
            --CONFIRM THAT THIS JOB IS SCHEDULED AND ENABLED TO ENSURE THAT ONLY ONE INCIDENT IS CREATED PER FAILURE
            
        
        BEGIN
            EXEC msdb.dbo.sp_send_dbmail 
                              @recipients = 'shyft-application-services@mdsol.pagerduty.com;cs_shyftsupport@mdsol.com'
                            , @body = @PagerDutyMESSAGE
                            , @subject = @PagerDutyMESSAGE
							, @from_address='ShyftProdSupport@mdsol.com'
        END
        
        /* Create a JIRA Ticket if There's an Error */
        IF 
        (@server LIKE 'PRO%' or @server like 'PRD%') --MAKE SURE THAT WE ARE RUNNING ON THE PROCESSING ENVIRONMENT 
        AND (SELECT TOP 1 message FROM msdb.dbo.sysjobs sj
            JOIN msdb.dbo.sysjobhistory sh  ON sj.job_id = sh.job_id
            WHERE step_name = '(Job outcome)'
            AND sJ.name = @jobname
            AND sj.name not like '%util%' AND sj.name not like '%autoshutdown%' AND sj.name not like '%Backups%' AND sj.name not like '%CLEANUP%' 
            AND sj.name not like '%maintenance%' AND sj.name not like '%OVERNIGHT JOB FAILURE CHECK%'   --IGNORE NON-CRITICAL JOBSs
            AND try_cast(try_cast(sh.run_date as varchar) as date) = cast(getdate() as date)
            ORDER BY msdb.dbo.Agent_datetime(sh.run_date, sh.run_time) DESC
            ) LIKE '%invoked by schedule%'
        BEGIN

		--email mdsol team
		   BEGIN
            EXEC msdb.dbo.sp_send_dbmail 
                              @recipients = 'cs_shyftsupport@mdsol.com'
                            , @body = @PagerDutyMESSAGE
                            , @subject = @PagerDutyMESSAGE
							, @from_address='ShyftProdSupport@mdsol.com'
		   END
            SELECT 'GENERATE JIRA TICKET'
            set @PshellString=N'%WINDIR%\System32\WindowsPowerShell\v1.0\powershell.exe C:\PowerShellScripts\AutoAutoBot.ps1'--'powershell.exe C:\PowerShellScripts\AutoAutoBot.ps1'
            IF OBJECT_ID('TPS_DBA.dbo.tblCmdShellOutput', 'U') IS NULL
                BEGIN
                    CREATE TABLE TPS_DBA.dbo.tblCmdShellOutput (id int identity(1,1), output nvarchar(max) null, InsertDate datetime DEFAULT CURRENT_TIMESTAMP)
                END
            CREATE TABLE #output (line varchar(255))
            INSERT #output (line) exec @rc = master..xp_cmdshell @PshellString
                
                --log output
                DELETE FROM #output WHERE line IS NULL
                
                DECLARE l_cursor CURSOR
                FOR SELECT line FROM #output
                
                OPEN l_cursor
                
                FETCH NEXT FROM l_cursor INTO @line
                
                WHILE @@FETCH_STATUS = 0
                BEGIN
                    SET @doc = @doc + @line
                    FETCH NEXT FROM l_cursor INTO @line
                END
                
                CLOSE l_cursor
                DEALLOCATE l_cursor
                DROP TABLE #output
                INSERT INTO TPS_DBA.dbo.tblCmdShellOutput (output) select @doc
                --INSERT TPS_DBA.dbo.tblCmdShellOutput (output) exec @rc = master..xp_cmdshell @PshellString
                SELECT * FROM TPS_DBA.dbo.tblCmdShellOutput WHERE output IS NOT NULL ORDER BY id
                --end log output
        END
            ELSE
        BEGIN       
            SELECT 'DO NOT GENERATE JIRA TICKET'
        END
        
RETURN 
END 
GO


