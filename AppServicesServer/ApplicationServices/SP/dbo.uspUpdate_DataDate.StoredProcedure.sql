USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspUpdate_DataDate]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspUpdate_DataDate]
AS
/*******************************************************************************************
Purpose:			
Inputs:				
Author:					
Created:			
Copyright:				
RunTime(HH:MM:SS):	00:00:01	
Execution:				
					EXEC ApplicationServices.dbo.uspUpdate_DataDate
 
Helpful Selects:	Source Tables:
						SELECT * FROM ApplicationServices.agd.tblMDSetting WHERE SettingName  = 'DataDate' 
						SELECT * FROM ApplicationServices.agd.tblMDSetting WHERE SettingName  = 'PreviousDataDate' 

					Staging Tables:
						SELECT * FROM 

					Reporting Tables:
						SELECT * FROM ApplicationServices.agd.tblMDSetting WHERE SettingName  = 'DataDate' 
						SELECT * FROM ApplicationServices.agd.tblMDSetting WHERE SettingName  = 'PreviousDataDate' 
						
*******************************************************************************************/
BEGIN
	SET NOCOUNT ON 

	INSERT INTO AGD.tblMdParentStoreProcedure
	SELECT @@PROCID, (SELECT AGD.udfGetStoreProcedure(@@PROCID))
	
	DECLARE @tblDataRunLog AS AGD.typDataRunLog
	INSERT INTO @tblDataRunLog  
	SELECT * FROM AGD.udfGetDataRunLogTable (2, @@PROCID,NULL)
	
	BEGIN TRY
		--DECLARE	@DataDate			VARCHAR(10) = '20170618'
		DECLARE	@DataDate			VARCHAR(10) = CONVERT(VARCHAR(8), GETDATE(),112)
		DECLARE	@PreviousDataDate	VARCHAR(10)	= CONVERT(VARCHAR(8), (DATEADD(DAY, -1, @DataDate)),112)
		
		IF DATEPART(dw, @DataDate) = 1 -- Sunday
		BEGIN
			SELECT	@PreviousDataDate = CONVERT(VARCHAR(8), (DATEADD(DAY, -2, @DataDate)),112)
		END
		ELSE IF DATEPART(dw, @DataDate) = 2 -- Monday
		BEGIN
			SELECT	@PreviousDataDate = CONVERT(VARCHAR(8), (DATEADD(DAY, -3, @DataDate)),112)
		END
					
		--PRINT	DATEPART(dw, @DataDate)
		--PRINT	@DataDate
		--PRINT	@PreviousDataDate
		
		EXEC ApplicationServices.agd.uspSetSetting 'DataDate', @DataDate
		EXEC ApplicationServices.agd.uspSetSetting 'PreviousDataDate', @PreviousDataDate

	END TRY
	
	BEGIN CATCH
	
		UPDATE	@tblDataRunLog 
		SET		ErrorMessage	= ERROR_MESSAGE(),
				ErrorNumber		= ERROR_NUMBER()	
	END CATCH
	
	EXEC AGD.uspInsertDataRunLog  @tblDataRunLog, 1

END




GO
