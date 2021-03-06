USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspRefreshandSendEmail]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspRefreshandSendEmail]
/*******************************************************************************************
Purpose:	
Inputs:		
Author:		
Created:	
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspRefreshandSendEmail
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM 
					
					---- Staging Tables:
						SELECT * FROM 

					---- Reporting Tables:
						SELECT * FROM 
						



*******************************************************************************************/

AS
BEGIN
	SET NOCOUNT ON 
	-----------
	--Logging
	-----------	
	INSERT INTO AGD.tblMdParentStoreProcedure
	SELECT @@PROCID, (SELECT AGD.udfGetStoreProcedure(@@PROCID))
	
	DECLARE @tblDataRunLog AS AGD.typDataRunLog
	INSERT INTO @tblDataRunLog  
	SELECT * FROM AGD.udfGetDataRunLogTable (2, @@PROCID,null) ---The 2 is the TPSExecProcesTypeId which represents logging for store procedure
	
	--------
	--Place code in between Code Start and Code End
	--------
	------
	--Code Start
	--------
	BEGIN TRY
		Declare @vchsql varchar(8000)
		declare @Recipients varchar(500)
		Declare @MessageBody varchar(max)='This is the delivery for the production metrics, for any questions, please reach out to Keith Martinek'
		declare @subjline varchar(500)=(select 'Production Metrics Delivery for '+CONVERT(varchar, getdate(), 23))
		Declare @convdate varchar(20)=(select replace(CONVERT(varchar, getdate(), 23),'-','_'))
		Declare @attachmentslist varchar(500)=(select 'F:\Templates\Production_Metrics_'+@convdate+'.xlsx')
		set @Recipients='kmartinek@shyftanalytics.com;tforman@shyftanalytics.com;syue@shyftanalytics.com;sbloch@shyftanalytics.com;nruhl@shyftanalytics.com'

		print @attachmentslist
		BEGIN
		set @vchsql='powershell.exe F:\Templates\MetricRefresh.ps1'
		EXEC xp_cmdshell @vchsql
		

		END

		EXEC msdb.dbo.sp_send_dbmail 
		@recipients=@Recipients
		,@subject=@subjline
		,@from_address='ProductionReporting@Shyftanalytics.com'
		,@body=@MessageBody
		,@body_format='HTML'
		,@file_attachments=@attachmentslist

	END TRY
	--------
	--Code End
	--------	
	
	-----------
	--Logging
	-----------	
	BEGIN CATCH
		----------
		--Update table variable with error message
		----------					   
		UPDATE @tblDataRunLog 
		SET ErrorMessage=ERROR_MESSAGE() 
                + ' Line:' + CONVERT(VARCHAR,ERROR_LINE())
                + ' Error#:' + CONVERT(VARCHAR,ERROR_NUMBER())
                + ' Severity:' + CONVERT(VARCHAR,ERROR_SEVERITY())
                + ' State:' + CONVERT(VARCHAR,ERROR_STATE())
                + ' user:' + SUSER_NAME()
                + ' in proc:' + ISNULL(ERROR_PROCEDURE(),'N/A')
			 + CASE WHEN OBJECT_NAME(@@PROCID) <> ERROR_PROCEDURE() THEN '<--' + OBJECT_NAME(@@PROCID) ELSE '' END   -- will display error from sub stored procedures
		  , ErrorNumber =ERROR_NUMBER()

	END CATCH

	----------
	--Log
	----------					   		   	
	EXEC AGD.uspInsertDataRunLog  @tblDataRunLog, 1 -----AGD.uspInsertDataRunLog will raise error if there was an error



END

GO
