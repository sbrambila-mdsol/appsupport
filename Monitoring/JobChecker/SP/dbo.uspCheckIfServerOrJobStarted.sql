USE [TPS_DBA]
GO

DROP PROCEDURE IF EXISTS dbo.[uspCheckIfServerOrJobStarted]
GO

/****** Object:  StoredProcedure [dbo].[uspCheckIfServerOrJobStarted]    Script Date: 3/12/2019 9:50:25 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspCheckIfServerOrJobStarted]
/*******************************************************************************************
Name:               uspCheckIfServerOrJobStarted 
Purpose:            Will fail if a job that was scheduled to kick off did not start at its scheduled time.
Inputs:             None
Author:             Aidan Fennessy
Created:            18th Sep 2018
History:            Date                Name                Comment
                    18th Oct 2018       Aidan Fennessy      Initial Creation

Copyright:
RunTime:            00:00:30 (HH:MM:SS)

Execution:          EXEC TPS_DBA.dbo.uspCheckIfServerOrJobStarted
					
					Deploy this procedure on your PRODUCTION server and create a job on your PRODUCTION server that calls this procedure.

*******************************************************************************************/
AS

BEGIN
SET NOCOUNT ON 
	
	BEGIN TRY
		DECLARE @srvr NVARCHAR(128), @statusval INT, @statusval1 nvarchar(max);
		SET @srvr = (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like '%processing%server%');
			
			--Attempt to ping processing server.
			BEGIN TRY
				EXEC @statusval = sp_testlinkedserver @srvr;
				--SET @statusval = SIGN(@@ERROR)
			END TRY
						
			BEGIN CATCH
				SET @statusval = SIGN(@@ERROR);
			END CATCH

			--Attempt to check that all jobs have kicked off as scheduled.
			BEGIN TRY
				Declare @CheckIfJobStarted varchar (max) = 'EXEC [' + @srvr + '].TPS_DBA.dbo.uspCheckIfJobStarted'  
				EXEC (@CheckIfJobStarted)
			END TRY
						
			BEGIN CATCH
				--SET @statusval1 = SIGN(@@ERROR);
				SET @statusval1 = ERROR_MESSAGE();
				--print ERROR_MESSAGE()
			END CATCH			

			IF @statusval <> 0 --If server is unresponsive then send alert that server is unresponsive.
				BEGIN
				    Declare @error varchar (max) = 'The processing server, ' + @srvr + ', is not responsive and either did not start or is currently hung.'  
					EXEC TPS_DBA.dbo.uspSlackErrorMessage @Message = @error, @Notify = '<!here>'
				END

			ELSE --Check if jobs started as scheduled.
				BEGIN
					IF (@statusval1) NOT LIKE '%DID NOT START AS SCHEDULED%' 
						BEGIN
							DECLARE @raisebadexecution NVARCHAR(max) = 'There was an error in executing uspCheckIfServerOrJobStarted on ' + @srvr + ': ' + @statusval1 + ''; 
							EXEC TPS_DBA.dbo.uspSlackErrorMessage @Message = @raisebadexecution
							RAISERROR (@raisebadexecution, 16, 1)
						END
					ELSE
						BEGIN
							DECLARE @findmessage NVARCHAR(max) = 'SELECT Message FROM [' + @srvr + '].TPS_DBA.dbo.tblSlackPassThroughMessages'; 
							
			   				DROP TABLE IF EXISTS TPS_DBA.dbo.tblSlackMessages; 
							CREATE TABLE TPS_DBA.dbo.tblSlackMessages (Message varchar(max))
							Insert into TPS_DBA.dbo.tblSlackMessages (Message)
							EXEC (@findmessage)
							DECLARE @message NVARCHAR(max) = (SELECT Message FROM TPS_DBA.dbo.tblSlackMessages); 
							
							IF @MESSAGE LIKE 'Job(s) started as scheduled'
								BEGIN
									PRINT 'Jobs and server started as scheduled'
								END
							ELSE --If jobs failed to start on processing then send alert that jobs failed to start as scheduled.
								BEGIN
									EXEC TPS_DBA.dbo.uspSlackErrorMessage @Message = @MESSAGE
								END
						END
				END
	
	END TRY
	
	BEGIN CATCH
		
		DECLARE @RaiseFinalErrorMessage VARCHAR(MAX) = 'There was an error in executing uspCheckIfServerStarted. ' 
                 + 'Error Message: '+ ERROR_MESSAGE()
		+        + ' Line:' + CONVERT(VARCHAR,ERROR_LINE())
		+        + ' Error#:' + CONVERT(VARCHAR,ERROR_NUMBER())
		+        + ' Severity:' + CONVERT(VARCHAR,ERROR_SEVERITY())
		+        + ' State:' + CONVERT(VARCHAR,ERROR_STATE())
		+        + ' user:' + SUSER_NAME()
		+        + ' in proc:' + ISNULL(ERROR_PROCEDURE(),'N/A')
		+     + CASE WHEN OBJECT_NAME(@@PROCID) <> ERROR_PROCEDURE() THEN '<--' + OBJECT_NAME(@@PROCID) ELSE '' END   -- will display error from sub stored procedures
	     
		RAISERROR (@RaiseFinalErrorMessage, 16, 1)
		 		  
	END CATCH


END



GO

