USE [ApplicationServices]
GO

/****** Object:  StoredProcedure [dbo].[uspCrushExpiration]    Script Date: 6/24/2020 4:02:40 PM ******/
DROP PROCEDURE [dbo].[uspCrushExpiration]
GO

/****** Object:  StoredProcedure [dbo].[uspCrushExpiration]    Script Date: 6/24/2020 4:02:40 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspCrushExpiration]
/*******************************************************************************************
Purpose: To	track each customer's crush expiration date and slack our channel when it is getting close to expiring
Inputs:		
Author:	Todd Forman and Harrison Southworth	
Created:	
Copyright:	6/24/2020
RunTime:	
Execution:	
					EXEC dbo.uspCrushExpiration
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM ApplicationServices.dbo.tblCrushSFTPPasswordExpiration
					
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
		DECLARE @ProjectCount int = 1
		DECLARE @projectname varchar(255)
		DECLARE @ExpirationDate date
		DECLARE @checkdate date
		DECLARE @Today date
		SET @Today = GETDATE()--'9/6/20'
		DECLARE @Message varchar(255)
		DECLARE @ProjectCrushURL VARCHAR(255)

		--WHILE LOOP TO GO THROUGH EACH CUSTOMER
		WHILE @ProjectCount <=  (SELECT COUNT(*) FROM ApplicationServices.dbo.tblCrushSFTPPasswordExpiration)
		BEGIN
			SET @ProjectName = (SELECT ProjectName FROM ApplicationServices.dbo.tblCrushSFTPPasswordExpiration where ProjectID = @ProjectCount)
			SET @ExpirationDate = (SELECT LastPasswordChangedDate FROM ApplicationServices.dbo.tblCrushSFTPPasswordExpiration where ProjectID = @ProjectCount)
			SET @ProjectCrushURL = (SELECT CrushSFTPURL FROM ApplicationServices.dbo.tblCrushSFTPPasswordExpiration where ProjectID = @ProjectCount)
			SET @checkdate = DATEADD(DD,85,CONVERT(DATE,@ExpirationDate))
			SET @Message=''+@ProjectName+' Crush SFTP password is SET to expire soon. Change the password at '+@ProjectCrushURL+''
			--print @message
			--print @checkdate
  
			 IF @Today < @checkdate
				 PRINT @ProjectName + ' Good ON ' + convert(varchar(10),@today,112)
 			 ELSE 
				EXEC TPS_DBA.dbo.uspSlackMessage @MESSAGE = @Message
			SET @ProjectCount = @ProjectCount + 1
		END
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


