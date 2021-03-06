USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspCreateFinancialForceIssueHours]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspCreateFinancialForceIssueHours]
/*******************************************************************************************
Purpose:	Create a table of Issue hours from FF
Inputs:		
Author:		Todd Forman
Created:	8/8/19
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspCreateFinancialForceIssueHours
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM 
					
					---- Staging Tables:
						SELECT * FROM 

					---- Reporting Tables:
						SELECT * FROM ApplicationServices.dbo.tblFFFinalHours
						



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
		TRUNCATE TABLE ApplicationServices.dbo.tblFFFinalHours
		INSERT INTO ApplicationServices.dbo.tblFFFinalHours
		SELECT convert(varchar(4),YEAR(date))+'_'+convert(varchar(2),MONTH(date)) as YearMth,Date,Client,Project,Task,Hours as TimeHrMin,Hours,FirstName,LastName 
		FROM ApplicationServices.dbo.[vwFFHours]
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
