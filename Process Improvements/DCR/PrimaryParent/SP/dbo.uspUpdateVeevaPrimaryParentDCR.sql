USE [<Customer>]
GO

IF OBJECT_ID('uspUpdateVeevaPrimaryParentDCR','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspUpdateVeevaPrimaryParentDCR]
GO

/****** Object:  StoredProcedure [dbo].[uspUpdateVeevaPrimaryParentDCR]    Script Date: 11/26/2019 10:05:48 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[uspUpdateVeevaPrimaryParentDCR]
/*******************************************************************************************
Purpose: To push Primary Parent updates back to Veeva	
Inputs:		
Author:	Todd Forman	
Created: 10/28/2019	
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspUpdateVeevaPrimaryParentDCR
 
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
	--update all feeds to inactive
		UPDATE <Customer>.AGD.tblMdDataFeed
		SET ACTIVE=0

	--set dcr feeds to active
		UPDATE <Customer>.AGD.tblMdDataFeed
		SET ACTIVE=1
		WHERE DataFeedName in ('Update Veeva DCR Account','Update Veeva DCR Header','Update Veeva DCR Line Item')
	
	--Run updates to veeva
		EXEC AGD.uspExecuteTaskManager 0
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


