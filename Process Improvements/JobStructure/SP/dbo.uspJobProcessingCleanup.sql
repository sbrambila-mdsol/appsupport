USE [TPS_DBA]
GO

IF OBJECT_ID('uspJobProcessingCleanup','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspJobProcessingCleanup]
GO

/****** Object:  StoredProcedure [dbo].[uspJobProcessingCleanup]    Script Date: 2/28/2020 10:35:17 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspJobProcessingCleanup]						
/*******************************************************************************************
Purpose:		Cleanup IsProcessing flag
Inputs:			
Author:			Dan Jun
Created:		01/23/2019
History:		Dan Jun		01/23/2019


EXEC dbo.uspJobProcessingCleanup


SELECT * FROM TPS_DBA.dbo.tblMdJobDataProcessing
SELECT * FROM TPS_DBA.dbo.tblMdJobScenarioStep
SELECT * FROM TPS_DBA.dbo.vwChainJobBreakdown ORDER BY ParentJobName,ChildJobName
SELECT * FROM TPS_DBA.dbo.vwJobActivityMonitor


UPDATE TPS_DBA.dbo.tblMdJobScenarioStep
SET IsProcessing = 0
WHERE IsProcessing = 1
*******************************************************************************************/
AS 
BEGIN
	SET NOCOUNT ON 
	
	BEGIN TRY
		--DECLARE VARIABLE
		DECLARE @TargetJobs TABLE (JobID INT);
		
		--SEEK 
		INSERT INTO @TargetJobs
		SELECT JDP.JobID
		FROM TPS_DBA.dbo.tblMdJobDataProcessing JDP
		LEFT JOIN (
			SELECT J.name  
			FROM msdb.dbo.sysjobactivity ja 
			JOIN msdb.dbo.sysjobs j 
			ON ja.job_id = j.job_id
			JOIN msdb.dbo.sysjobsteps js
				ON ja.job_id = js.job_id
				AND ISNULL(ja.last_executed_step_id,0)+1 = js.step_id
			WHERE ja.session_id = (SELECT TOP 1 session_id FROM msdb.dbo.syssessions ORDER BY agent_start_date DESC)
			AND start_execution_date is not null
			AND stop_execution_date is null
			) JAM  -- CHECK FOR CURRENTLY RUNNING JOBS ACCORDING TO JOB ACTIVITY MONITOR
			ON JAM.name = JDP.JobName
		WHERE JDP.IsProcessing = 1
		AND JAM.name IS NULL  --TARGET JOBSS WHICH ARE 'IsProcessing' but are not running per job activity monitor (join results in null)

		--Cleanup IsProcessing Flag
		UPDATE TPS_DBA.dbo.tblMdJobDataProcessing
		SET IsProcessing = 0
		WHERE JobID IN (SELECT JobID FROM @TargetJobs)


		UPDATE TPS_DBA.dbo.tblMdJobScenarioStep
		SET IsProcessing = 0
		WHERE JobID IN (SELECT JobID FROM @TargetJobs)


	END TRY


	BEGIN CATCH
		
		 DECLARE @ErrorMessage VARCHAR(MAX) = 'There was an error in executing uspJobProcessingCleanup. ' 
                 + 'Error Message: '+ ERROR_MESSAGE()
                + ' Line:' + CONVERT(VARCHAR,ERROR_LINE())
                + ' Error#:' + CONVERT(VARCHAR,ERROR_NUMBER())
                + ' Severity:' + CONVERT(VARCHAR,ERROR_SEVERITY())
                + ' State:' + CONVERT(VARCHAR,ERROR_STATE())
                + ' user:' + SUSER_NAME()
                + ' in proc:' + ISNULL(ERROR_PROCEDURE(),'N/A')
             + CASE WHEN OBJECT_NAME(@@PROCID) <> ERROR_PROCEDURE() THEN '<--' + OBJECT_NAME(@@PROCID) ELSE '' END   -- will display error from sub stored procedures
		  
	END CATCH

END


GO


