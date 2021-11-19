USE <ProcessingDB>
GO

drop procedure if exists [dbo].[uspEmailVendorFileNotFound]
go

/****** Object:  StoredProcedure [dbo].[uspEmailVendorFileNotFound]    Script Date: 4/11/2019 5:14:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspEmailVendorFileNotFound]
/*******************************************************************************************
Purpose:	If current download scenario fails, send email to vendor with files not found. 
Inputs:		
Author:				Aidan Fennessy
Created:			04/18/2019
Copyright:	
RunTime:	
Execution:	
					--Run with the current executing ScenarioTypeID
					EXEC dbo.uspEmailVendorFileNotFound '9561, 9559, 9558, 9560', @failscenariowhennotfound = 0

					EXEC dbo.uspEmailVendorFileNotFound 
					'9502,9512,9533,9535,9537,9539,9541,9543,9558,9559,9560,9561,9562,9563,9564,9565', @failscenariowhennotfound = 0

					SELECT * FROM tps_dba.dbo.tblserversetting where settingname like '%ClientName%'
Change History:		


Helpful Selects:

					---- Source Tables:
						SELECT * FROM TPS_DBA.dbo.tblMdVendorScenarioMap

SELECT distinct(TPSScenarioTypeID), importtablename, * FROM greenwich.agd.tblmddatafeed where tasktype like 'sftpdownload' and (datafeeddescription like '%cvs%' or datafeeddescription like '%amber%' or datafeeddescription like '%accredo%' or datafeeddescription like '%acaria%')


SELECT distinct(TPSScenarioTypeID), importtablename, * FROM greenwich.agd.tblmddatafeed where tasktype like '%import%' and (datafeeddescription like '%cvs%' or datafeeddescription like '%amber%' or datafeeddescription like '%accredo%' or datafeeddescription like '%acaria%')


					---- Reporting Tables:
						SELECT * FROM dbo.tblDF_ADP_Employee_PREVIMPORT

Important Implementation Notes:
	1) Must be implemented in DOWNLOAD scenario with ContinueOnFail = 1
	2) Emails will not be sent about files set to IgnoreFileNotFound 
	3) Must set DataDateLogic for the relevant processing db
						
3 options for running: 
	1) Input nothing, runs for current scenario
	2) Input one or multiple scenarios, looks for files not found in each
	3) Input one vendor, looks for files not found in each scenario for that vendor

To be built:
	1. A log of all files that were emailed about to avoid sending duplicate emails


To QA:
	1) Are emails sent out after a file was subsequently brought in successfully for that feed? (They shouldn't be)
	2) Are emails sent out when the datadate is different than should normally be expected (i.e. set other than previous work day)
	3) Is one individual email sent out re all missing files for each vendor instead of multiple emails to the same vendor regarding different files?
	4) if no scenario is provided the process reports files not found for any scenarios that are run and that have the procedure in the scenario
	5) That no emails are sent out for any inactive feeds in tblMdVendorScenarioMap 
	6) That no emails are sent out when AGD.udfGetTPS_DBA_Setting('SendVendorEmails') returns 0
	7) That when @FailScenarioWhenNotFound = 1 that the scenario fails
	--Similarly, if 0 or NULL, that the scenario completes successfully.




*******************************************************************************************/
(
	@ScenarioTypeID varchar(200) = NULL,
	@Vendor varchar(200) = NULL,
	@FailScenarioWhenNotFound bit
)
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

	/*
	--FOR TESTING
	DECLARE 
	@ScenarioTypeID varchar(50) = '9543, 9512, 9561',
	@Vendor varchar(100) = NULL,
	@FailScenarioWhenNotFound bit = 0  
	--SET @Vendor  = 'amber' 
	*/
	
	DECLARE @CustomerName varchar(100) = AGD.udfGetTPS_DBA_Setting('ClientName')
	DECLARE @ERRORMEESSAGE NVARCHAR(MAX)
	DECLARE @DataDate varchar(50) = AGD.udfGetSetting('DataDate')
	DECLARE @GetDate varchar(50) = GETDATE() 
	DECLARE @SendVendorEmails bit = AGD.udfGetTPS_DBA_Setting('SendVendorEmails')
	DECLARE @xml NVARCHAR(MAX)
	DECLARE @body NVARCHAR(MAX)
	DECLARE @time VARCHAR(100) = convert(varchar, @GetDate, 22) 
	DECLARE @DataDateLogic int = AGD.udfGetSetting('DataDateLogic')
	DECLARE @ENVIRONMENT VARCHAR(10) = AGD.udfGetTPS_DBA_Setting('Environment')
	DECLARE @Date    VARCHAR (20) = AGD.udfformatdate(@GetDate,'YYYY-MM-DD')-- PRINT @DATE --convert(varchar, getdate(), 22) 	DECLARE @subject NVARCHAR(100) =  @CustomerName + ' File(s) Not Found - '+@Date
	DECLARE @RecipientEmail varchar(1000)  = ''
	DECLARE @Addressee VARCHAR(100) = ''
	DECLARE @VendorName VARCHAR(100) = ''
	DECLARE @CopyRecipients varchar(1000) = ''
	DECLARE @BlindCopyRecipients varchar(1000) = ''
	DECLARE @InternalEmail varchar(1000) = ''
	DECLARE @ClientEmail varchar(1000) = ''
	DECLARE @VendorSpecificMessage varchar(1000) = ''
	DECLARE @ReplyTo varchar(1000) = ''
 	DECLARE @TableTail NVARCHAR(max)
	DECLARE @ExtractLocation VARCHAR(1000) = '[ExtractLocation]\[Environment]\[DataDate]\'
	DECLARE @OutputFileName VARCHAR(1000) = 'FilesNotFound'		--'FilesNotFound.csv'
	DECLARE @FileLocation varchar(1000) = AGD.udfReplaceSettingNameInString(@ExtractLocation)+@OutputFileName;
	DECLARE @VendorEmail varchar(1000)
	DECLARE @VchSql VARCHAR(MAX)	
	DECLARE @FAILEDIMPORTS varchar(1000)  = ''
	DECLARE @ErrorMessage varchar(1000)  = '' 
	--select DATEADD(DD,CASE WHEN DATENAME(dw, @DataDate) = 'Friday' THEN DATEADD(dd, 3, @DataDate) ELSE DATEADD(dd,@DataDateLogic,@DataDate) END, TRY_CAST(AGD.udfGetSetting('DataDate')) AS DATE))
	--select AGD.udfGetSetting('DataDateLogic')
	--DATEADD(DD,@DataDateLogic, TRY_CAST(AGD.udfGetSetting('DataDate') AS DATE))
	--greenwich.agd.uspupdatedatadate 
	
	DROP TABLE IF EXISTS #ScenarioList; 
	CREATE TABLE #ScenarioList(ScenarioList VARCHAR(50))

	INSERT INTO #ScenarioList (ScenarioList)		
	(SELECT * FROM [TPS_DBA].[dbo].[udfSplitstring](@ScenarioTypeID, ','))

	DROP TABLE IF EXISTS #RunIds
	CREATE TABLE #RunIds (TPSRunId int, TPSScenarioTypeID int) 

	IF @Vendor IS NOT NULL OR @ScenarioTypeID IS NOT NULL 
		BEGIN
				DROP TABLE IF EXISTS #tblMdVendorScenarioMapRanked
				SELECT PrimaryRank=RANK() OVER (PARTITION BY VendorName ORDER BY TPSScenarioTypeId), * INTO #tblMdVendorScenarioMapRanked  FROM TPS_DBA.dbo.tblMdVendorScenarioMap
				--SELECT * FROM #tblMdVendorScenarioMapRanked

				DECLARE @Rank VARCHAR(MAX) 
				--Begin loop for multiple scenario checks
				DECLARE Cur_Scenarios CURSOR Local Fast_Forward FOR SELECT TPSScenarioTypeID FROM #tblMdVendorScenarioMapRanked WHERE VendorName = @Vendor OR TPSScenarioTypeId IN (SELECT ScenarioList FROM #ScenarioList)

				--SELECT TPSScenarioTypeID FROM #tblMdVendorScenarioMapRanked WHERE VendorName = @Vendor OR TPSScenarioTypeId IN (SELECT ScenarioList FROM #ScenarioList)

				OPEN Cur_Scenarios
			
				FETCH NEXT FROM Cur_Scenarios INTO @Rank
			
				WHILE @@FETCH_STATUS = 0

				BEGIN
					IF @ScenarioTypeID IS NOT NULL 
					BEGIN 
						SET @VchSql = 'SELECT distinct top 1 TPSRunID, TPSScenarioTypeID FROM greenwich.agd.tblmddatarunlog where TPSScenarioTypeId = (SELECT TPSScenarioTypeId FROM #tblMdVendorScenarioMapRanked WHERE TPSScenarioTypeId = ('+@Rank+') --AND PrimaryRank = '+@Rank+'
						) ORDER BY TPSRunID desc'
						--PRINT @VchSql
					END
					IF @Vendor IS NOT NULL 
					BEGIN 
						SET @VchSql = 'SELECT distinct top 1 TPSRunID, TPSScenarioTypeID FROM greenwich.agd.tblmddatarunlog where TPSScenarioTypeId = (SELECT TPSScenarioTypeId FROM #tblMdVendorScenarioMapRanked WHERE VendorName = ''' + @Vendor + ''' AND TPSScenarioTypeId = ('+@Rank+') --AND PrimaryRank = '+@Rank+'
						) ORDER BY TPSRunID desc'
						--PRINT @VchSql
					END

					INSERT INTO #RunIds EXEC (@VchSql)

				FETCH NEXT FROM Cur_Scenarios INTO @Rank
				END
			
				CLOSE Cur_Scenarios
				DEALLOCATE Cur_Scenarios 
		END
	ELSE 
		BEGIN 
			DROP TABLE IF EXISTS #RunIds 
			--CREATE TABLE #RunIds (TPSRunId int, TPSScenarioTypeID int)  
			INSERT INTO #RunIds SELECT AGD.udfGetSetting('TPSRunId'), AGD.udfGetSetting('TPSScenarioTypeId')
			--SELECT * FROM #RunIds
		END
	
		--Find all files that were not found 
		DROP TABLE IF EXISTS TPS_DBA.dbo.tblFilesNotFound
		CREATE TABLE TPS_DBA.dbo.tblFilesNotFound(ExpectedFile VARCHAR(max), VendorEmail VARCHAR(max), TPSScenarioTypeId VARCHAR(max))

		INSERT INTO TPS_DBA.dbo.tblFilesNotFound (ExpectedFile, VendorEmail, TPSScenarioTypeId)		
		(SELECT iml.FilePath, md.VendorEmail, iml.TPSScenarioTypeId FROM [AGD].[tblMdDatafeedImportlog] iml					--GRAB ALL FilePaths (including filename) AND corresponding vendor email
		JOIN agd.tblMdDataFeed df ON df.TPSDataFeedId = iml.TPSdatafeedid
		JOIN TPS_DBA.dbo.tblMdVendorScenarioMap md ON md.TPSScenarioTypeId = iml.TPSScenarioTypeId 
		WHERE iml.TPSSCenariotypeID IN (SELECT TPSScenarioTypeId FROM #RunIds)												--for the currently running scenario OR input scenario(s)
		--AND --iml.RunID IN (SELECT TPSRunID FROM #RunIds)																		--and the currently running RunId OR input RunId(s)
		AND CAST(iml.ImportedDate AS DATE) = DATEADD(DD,CASE WHEN @DataDateLogic > 0 AND DATENAME(dw, @GetDate) = 'Monday' THEN 2 + @DataDateLogic ELSE @DataDateLogic END, TRY_CAST(@DataDate AS DATE))  --and ensure that we do not send an email when we have deviated from normal operations (i.e. changed DataDate)
		--AND iml.ImportSucceeded = 'N' AND iml.ImportedFileName LIKE 'File Not Found'										--for all cases when an import failed and a file was not found
		--AND df.IgnoreFileNotFound != 1																						--and only for files that we expect to find
		--AND md.Active = 1																									--and only for scenarios that we want to send FileNotFound emails for
		)
		SELECT * FROM TPS_DBA.dbo.tblFilesNotFound

	--------------------------------------------------WHILE LOOP TO LOOP THROUGH VENDORS/DISTINCT EMAIL CONTACTS IF MORE THAN ONE--------------------------------------------------
	IF (SELECT COUNT(VendorEmail) FROM TPS_DBA.dbo.tblFilesNotFound) > 0
		BEGIN
				DROP TABLE IF EXISTS #SendVendorFilesNotFound
				SELECT PrimaryRank=RANK() OVER (PARTITION BY VendorEmail ORDER BY TPSScenarioTypeId), * INTO #SendVendorFilesNotFound  FROM TPS_DBA.dbo.tblFilesNotFound
				--SELECT * FROM #SendVendorFilesNotFound

				DECLARE @NextEmail VARCHAR(1000) 
				--Begin loop for sending one individual email to each vendor email
				DECLARE Cur_Emails CURSOR FOR (SELECT DISTINCT(VendorEmail) FROM #SendVendorFilesNotFound)
				OPEN Cur_Emails
			
				FETCH NEXT FROM Cur_Emails INTO @NextEmail
			
				WHILE @@FETCH_STATUS = 0
			
				BEGIN
						--SELECT @NextEmail AS 'NEXTEMAILINLOOP'
						SET @OutputFileName = 'FilesNotFound'
						SELECT TOP 1
						@RecipientEmail = ISNULL(VendorEmail, ''),
						@Addressee = ISNULL(Addressee, ''),
						@VendorName	= ISNULL(VendorName, ''),
						@CopyRecipients = ISNULL(CopyRecipients, ''),
						@BlindCopyRecipients = ISNULL(BlindCopyRecipients, ''),
						@InternalEmail = ISNULL(SHYFTEmail, ''),
						@ClientEmail = ISNULL(ClientEmail, ''),
						@VendorSpecificMessage = ISNULL(VendorSpecificMessage, ''),
						@ReplyTo = ISNULL(ReplyTo, '')
						FROM TPS_DBA.dbo.tblMdVendorScenarioMap
						WHERE VendorEmail = @NextEmail 
						AND Active = 1
						--NOT IDEAL TO SELECT TOP 1 FOR VENDOR EMAIL BECAUSE THERE COULD TECHNICALLY BE DIFFERENT CONFIGS FOR EACH FEED

						DROP TABLE IF EXISTS TPS_DBA.dbo.tblSendVendorFilesNotFound
						SELECT ExpectedFile INTO TPS_DBA.dbo.tblSendVendorFilesNotFound FROM #SendVendorFilesNotFound WHERE VendorEmail = @NextEmail --AND PrimaryRank = @NextEmail
						--SELECT * FROM TPS_DBA.dbo.tblSendVendorFilesNotFound

						SET @OutputFileName = @OutputFileName + @VendorName + '.csv'
						SET @FileLocation = AGD.udfReplaceSettingNameInString(@ExtractLocation)+@OutputFileName;
						--select @OutputFileName
						--select @FileLocation
						--select @ExtractLocation

						EXEC AGD.uspExport	@InputTable			= 'TPS_DBA.dbo.tblSendVendorFilesNotFound',
											@IncludeHeaders		= 1, 
											@InputColumns		= 'ExpectedFile', 
											@Delimiter			= '|',
											@OutputFileName		= @OutputFileName,
											@ExtractLocation	= @ExtractLocation,
											@QuotedFields		= 0; 
					
						SET @xml = NULL
						SET @body = NULL
						SET @TableTail = NULL
						--Insert files into html table
						SET @xml = CAST(( SELECT [ExpectedFile] AS 'td'
						FROM  TPS_DBA.dbo.tblSendVendorFilesNotFound
						FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX))

						SET @body ='<html><body> Hi ' + @Addressee + ',<br>  <br> 
								 
									 As of '+@time+' EST we have not received the following files at their expected delivery locations.  <br>  <br> 
									<table border = 1> 
									<tr>
									<th> Expected File Name & Location </th></tr>
									'
						--Signature in email
						SET @TableTail =
						'(Please note that an asterisk (*) serves as a wildcard and matches any number of characters in-between preceding and subsequent strings of text.)<br>
						<br>Could you please investigate and provide an ETA on when we might be able to expect these files? '+@VendorSpecificMessage+' <br> <br>' +
						 N'
						 Thanks, <br> <br> ' +
						 N'The Shyft Team'

						--fianl body of the email by concatination
						SET @body = @body + @xml +  +'</table></body></html>'  + @TableTail
								  			
						IF @SendVendorEmails = 1 AND (@ENVIRONMENT = 'PROCESSING' OR @ENVIRONMENT = 'Production') AND (SELECT COUNT(ExpectedFile) FROM TPS_DBA.dbo.tblSendVendorFilesNotFound) > 0
							BEGIN 
								SELECT @RecipientEmail
								EXEC msdb.dbo.sp_send_dbmail
								@profile_name = 'ShyftAnalyticsEmailSystem', -- replace with your SQL Database Mail Profile 
								@body = @body ,
								@file_attachments = @FileLocation,
								@body_format ='HTML',
								@importance = 'High',
								@recipients = @RecipientEmail, -- replace with your email address
								@reply_to = @ReplyTo,
								@from_address = @ReplyTo,
								@copy_recipients = @CopyRecipients,
								@blind_copy_recipients = @BlindCopyRecipients, 
								@subject = @subject;

							END

						--IF (SELECT * FROM TPS_DBA.dbo.tblFilesNotFound) IS NOT NULL AND (@SendVendorEmails != 1 OR (@ENVIRONMENT != 'PROCESSING' OR @ENVIRONMENT != 'Production')) 
						--if  (@SendVendorEmails != 1 OR (@ENVIRONMENT != 'PROCESSING' OR @ENVIRONMENT != 'Production'))  
						ELSE 
							BEGIN
								IF (SELECT COUNT(ExpectedFile) FROM TPS_DBA.dbo.tblSendVendorFilesNotFound) > 0
									BEGIN 
										EXEC msdb.dbo.sp_send_dbmail
											@profile_name = 'ShyftAnalyticsEmailSystem', -- replace with your SQL Database Mail Profile 
											@body = @body,
											@file_attachments = @FileLocation,
											@body_format ='HTML',
											@importance = 'High',
											@recipients = @InternalEmail, -- We only want to send internally 
											@reply_to = @ReplyTo,
											@from_address = @ReplyTo,
											--@copy_recipients = @CopyRecipients,
											--@blind_copy_recipients = @BlindCopyRecipients 
											@subject = @subject;
									END
							END


				FETCH NEXT FROM Cur_Emails INTO @NextEmail
			END
			
			CLOSE Cur_Emails
			DEALLOCATE Cur_Emails
		END


	IF @SendVendorEmails != 1 PRINT 'TPS_DBA Setting SendVendorEmails flag is not set to send vendor emails.'
	IF (SELECT COUNT(ExpectedFile) FROM TPS_DBA.dbo.tblFilesNotFound) > 0 PRINT 'FILES NOT FOUND.'
	IF (SELECT COUNT(ExpectedFile) FROM TPS_DBA.dbo.tblFilesNotFound) = 0 PRINT 'ALL FILES FOUND.'
	
	--DECLARE TABLES THAT WERE REVERTED BECAUSE OF A FAILED IMPORT THAT WASN'T CAUSED BY A FILE NOT FOUND
	

	SELECT @FAILEDIMPORTS = @FAILEDIMPORTS + ExpectedFile + ' 
> ' 
	FROM  TPS_DBA.dbo.tblFilesNotFound 
	SET @ErrorMessage = 'The following files were not found and emails were sent to the corresponding vendor(s). 
> ' + @FAILEDIMPORTS + '
'	
	--Send Slack message 
	IF (SELECT COUNT(ExpectedFile) FROM TPS_DBA.dbo.tblFilesNotFound) > 0
	BEGIN 
		EXEC TPS_DBA.DBO.uspSlackMessage @message = @errormessage
	END

	IF @FailScenarioWhenNotFound = 1 AND (SELECT COUNT(ExpectedFile) FROM TPS_DBA.dbo.tblFilesNotFound) > 0
	BEGIN 
		RAISERROR(@ErrorMessage, 16, 1)
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
		  , ErrorNumber =ERROR_NUMBER()	

	END CATCH

	----------
	--Log
	----------					   		   	
	EXEC AGD.uspInsertDataRunLog  @tblDataRunLog, 1 -----AGD.uspInsertDataRunLog will raise error if there was an error


END




GO