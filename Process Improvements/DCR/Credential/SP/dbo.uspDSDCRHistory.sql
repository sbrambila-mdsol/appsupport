USE [BLUEPRINT]
GO

IF OBJECT_ID('uspDSDCRHistory','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspDSDCRHistory]
GO

/****** Object:  StoredProcedure [dbo].[uspDSDCRHistory]    Script Date: 6/29/2020 11:49:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[uspDSDCRHistory]
/*******************************************************************************************
Purpose:	
Inputs:		
Author:		
Created:	
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspDSDCRHistory
 
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
		--Add new records
		INSERT INTO blueprint.dbo.DSHistoryDCRItems
		select  C.Id,C.Name,C.RecordTypeId,convert(date,C.CreatedDate) as CreatedDate,C.Notes_vod__c,C.Status_vod__c,
			CONVERT(DATE,C.LastModifiedDate) AS LastModifiedDate,C.LastModifiedById
		FROM BLUEPRINT_IM.DBO.tbldfVeevaDataChangeRequest as C
			LEFT JOIN blueprint.dbo.DSHistoryDCRItems as D on C.Id=D.Id
		WHERE D.Id IS NULL

		--Process completed ones
		UPDATE D
		SET Status_vod__c=C.Status_vod__c,LastModifiedById=C.LastModifiedById,LastModifiedDate=C.LastModifiedDate
		FROM blueprint.dbo.DSHistoryDCRItems AS D
			INNER JOIN BLUEPRINT_IM.DBO.tbldfVeevaDataChangeRequest as C ON D.Id=C.Id
		WHERE C.Status_vod__c IS NOT NULL
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


