USE [VERASTEM]
GO

IF OBJECT_ID('uspTriggersNoAffiliation','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspTriggersNoAffiliation]
GO
/****** Object:  StoredProcedure [dbo].[uspTriggersNoAffiliation]    Script Date: 6/29/2020 4:44:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspTriggersNoAffiliation]
/*******************************************************************************************
Purpose: To identify trigger entity id records with no affiliation	
Inputs:		
Author:		Todd Forman
Created:	6/29/2020
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspTriggersNoAffiliation
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM 
					
					---- Staging Tables:
						SELECT * FROM 

					---- Reporting Tables:
						SELECT * FROM verastem.dbo.tblTriggerEntitywithNoAffiliationsTask9
						



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
		INSERT INTO dbo.tblTriggerEntitywithNoAffiliationsTask9 (HCPEntityID,FirstName,LastName,VeevaID,SpecialtyFlag,InsertDate)
		SELECT a.HCPEntityId, b.FirstName, b.LastName, b.VeevaID, b.SpecialtyFlag, CONVERT(VARCHAR(10),GETDATE(),120) 
		FROM verastem..tblStgTriggers a
			INNER JOIN verastem_cm..vwHCPMaster b on a.HCPEntityId = b.HCPEntityID
		WHERE AffiliationID is null and SpecialtyFlag = 1
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


