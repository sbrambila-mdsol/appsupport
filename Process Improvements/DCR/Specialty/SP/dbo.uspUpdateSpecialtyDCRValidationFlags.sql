USE [VERASTEM]
GO

IF OBJECT_ID('uspUpdateSpecialtyDCRValidationFlags','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspUpdateSpecialtyDCRValidationFlags]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[uspUpdateSpecialtyDCRValidationFlags]
/*******************************************************************************************
Purpose: To updated valid records to push to Veeva for Specialty DCR requests	
Inputs:		
Author:	Rimona Saikia	
Created: 11/24/2019	
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspUpdateSpecialtyDCRValidationFlags
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM 
					
					---- Staging Tables:
						SELECT * FROM tblstgVeevaDataChangeRequest
						SELECT * FROM tblstgVeevaDataChangeRequestLine

						SELECT * FROM tblstgVeevaSpecialtyDCR

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
		
		--update flags
		UPDATE S
		SET VALID=1
		FROM VERASTEM.DBO.tblstgVeevaDataChangeRequest AS S
			INNER JOIN VERASTEM_IM.DBO.tblstgVeevaDataChangeRequestValid AS V on S.Id =V.id
		WHERE V.Valid=1

		UPDATE S
		SET VALID=1
		FROM VERASTEM.DBO.tblstgVeevaDataChangeRequestLine AS S
			INNER JOIN VERASTEM_IM.DBO.tblstgVeevaDataChangeRequestLineValid AS V ON S.Id=V.Id
		WHERE V.Valid=1

		UPDATE S
		SET VALID=1
		FROM VERASTEM.DBO.tblstgVeevaSpecialtyDCR AS S
			INNER JOIN VERASTEM_IM.DBO.tblstgVeevaSpecialtyDCRValid AS V ON S.Id=V.Id
		WHERE V.Valid=1

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


