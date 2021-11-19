USE TPS_DBA
GO
DROP PROCEDURE IF EXISTS dbo.uspCreateDataProcessingJob

GO
CREATE PROCEDURE dbo.uspCreateDataProcessingJob
/*******************************************************************************************
Purpose:		
Inputs:		
Author:			Crichton
Created:		9/2018
Copyright:	
Change History: 
RunTime:	

Sample Execution: 

						

						EXEC	dbo.uspCreateDataProcessingJob
									@JobName				= N'Daily: Update DataDate & Create Directory'
						--verification
						SELECT * FROM msdb.dbo.sysjobs WHERE name='Daily: Update DataDate & Create Directory'



*******************************************************************************************/
(
	@JobName				NVARCHAR(128)
	,@DeleteUnusedSchedule	BIT	= 0
)
AS 
BEGIN 
	DECLARE @JobOwner NVARCHAR(128),
			@ErrorMessage VARCHAR(MAX);


	IF EXISTS (SELECT 1 FROM master.sys.dm_server_services WHERE servicename = 'SQL Server Agent (MSSQLSERVER)' AND service_account LIKE '%@%')
	BEGIN
		SET @JobOwner = (SELECT 'TPSINTERNAL\'+SUBSTRING(service_account,1,CHARINDEX('@',service_account)-1) FROM master.sys.dm_server_services WHERE servicename = 'SQL Server Agent (MSSQLSERVER)');
		IF NOT EXISTS (SELECT 1 FROM master.dbo.syslogins WHERE name = @JobOwner)
		BEGIN
			SET @ErrorMessage = 'Service account '''+CAST(@JobOwner AS VARCHAR)+''' is not a valid user';
			RAISERROR(@ErrorMessage,16,1);
		END
	END
	ELSE
	BEGIN
		SET @JobOwner = (SELECT service_account FROM master.sys.dm_server_services WHERE servicename = 'SQL Server Agent (MSSQLSERVER)') 
		SET @ErrorMessage = 'Service account '''+COALESCE(CAST(@JobOwner AS VARCHAR),'Account Not Found')+''' is not in the expected format. Expected format is svcaccount@tpsinternal.com';
		RAISERROR(@ErrorMessage,16,1);
	END
	
	DECLARE @HasError BIT = 0
	IF NOT EXISTS(SELECT 1 FROM dbo.tblMdJobDataProcessing WHERE JobName = @JobName)
	BEGIN
		RAISERROR ('Job name  not found in tblMdJobDataProcessing.  No job created.',16,1)
		SET @HasError = 1
	END

	IF @HasError=0
	BEGIN
		DECLARE @JobScript NVARCHAR(4000) = (SELECT dbo.udfGetDataProcessingJobDropCreateScript(@JobName,@DeleteUnusedSchedule,@JobOwner))
		BEGIN TRY			
			EXEC sp_executesql @JobScript			
		END TRY
		BEGIN CATCH
			PRINT ERROR_MESSAGE()
			DECLARE @ErrorMsg NVARCHAR(4000) = N'Error executing the following: ' + @JobScript;
			RAISERROR (@ErrorMsg,16,1)
		END CATCH
	END
	
END