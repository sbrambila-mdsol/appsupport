USE [TPS_DBA]
GO

IF OBJECT_ID('TPS_DBA.dbo.uspFindLatestErrorInfo_MA', 'U') IS NOT NULL
BEGIN 
	DROP PROCEDURE dbo.uspFindLatestErrorInfo_MA
END

DROP PROCEDURE IF EXISTS [dbo].[uspFindLatestErrorInfo_MA]
GO

/****** Object:  StoredProcedure [dbo].[uspFindLatestErrorInfo_MA]    Script Date: 12/17/2019 4:05:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[uspFindLatestErrorInfo_MA]
/*******************************************************************************************
Name:               uspFindLatestErrorInfo
Purpose:            Generates tables storing error information for Auto Ticket Creation.
Inputs:             None
Author:             Mike Araujo
Created:            29th Nov 2019
History:            Date                Name                Comment
                    29th Nov 2019		Mike Araujo		Initial Creation

Copyright:
RunTime:            00:00:00 (HH:MM:SS)

Execution:          EXEC TPS_DBA.dbo.uspFindLatestErrorInfo_MA
NOTES:
					Creates TPS_DBA.dbo.ErrorResults for the purpose of AutoBot powershell JIRA ticket 
					creator to be able to find the latest error information. Used for App Serv Error Console

					Placing this script within a procedure allows for updates to the error 
					finding query without updating and re-signing the powershell.
					
*******************************************************************************************/
(
	@@RunID nvarchar(500) =  NULL
)
AS
BEGIN

DROP TABLE IF EXISTS #FailedJobs

DROP TABLE IF EXISTS #FailTimes

DROP TABLE IF EXISTS #SystemErrors

DROP TABLE IF EXISTS #QADBs

DROP TABLE IF EXISTS #RunAndScenID

DROP TABLE IF EXISTS ##ImportlogError

DROP TABLE IF EXISTS ##SFerror

DROP TABLE IF EXISTs #TaskQueue

DROP TABLE IF EXISTS ##DataFeed

DROP TABLE IF EXISTS ##datafeedID

DROP TABLE IF EXISTS ##QAresults

DROP TABLE IF EXISTS ##DataFeedDownload

DROP TABLE IF EXISTS ##DataRun

DROP TABLE IF EXISTS #ErrorResults
    
DECLARE @SQL nvarchar(max)

CREATE TABLE #ErrorResults
(
ServerName varchar(50),
JobName varchar(max),
StepName varchar(max),
SystemError varchar(max),
SystemCommand varchar(max),
DatabaseName varchar(500),
ScenarioTypeID varchar(25),
TaskQueueID varchar (25),
TaskStartTime varchar (255),
TaskEndTime varchar (255),
TaskQueueError nvarchar(max),
RunID varchar(25),
Datadate varchar(255),
ImportID varchar(25),
FilePath varchar(7000),
ImportTableName varchar(1000),
ImportedFileName varchar(1000),
DatafeedID varchar(25),
RecordsLoaded varchar (25),
ImportErrorMessage nvarchar(max),
SFobject varchar(512),
SFid varchar (512),
SFerror varchar(max),
SFTPpath VARCHAR(MAX),
SFTPUsername VARCHAR(MAX),
SFTPpassword VARCHAR(MAX),
ChildFileMask varchar(250),
IsZipFile varchar(25),
DataFeedLocation varchar(max),
DataFeedName varchar(max),
DataFeedDescription varchar(max),
LoadOrder varchar(25),
StartLine varchar(25),
DataFeedTypeID varchar(25),
Active varchar(25),
AppendToTable varchar(25),
Delimiter varchar(50),
MaxColumns varchar(25),
Worksheets varchar(50),
TaskType varchar(50),
FileDate varchar(50),
IgnoreFileNotFound varchar(25),
DropTable varchar(25),
QAqueryID int,
QAresult decimal(19,4),
ExpectedQAresult int,
QueryDescription varchar (max),
QAquery varchar(max),
FailThreshold int,
QAinsertDate datetime
)

SELECT je.[name], 
	   je.step_name, 
	   je.run_time,
	   CompletionTime INTO #FailedJobs
FROM   (SELECT jh.instance_id, 
			   j.[NAME], 
			   js.step_name, 
			   jh.sql_severity, 
			   jh.message, 
			   jh.run_date, 
			   jh.run_time, 
			   jh.run_duration, 
			   js.step_id, 
			   msdb.dbo.Agent_datetime(jh.run_date, jh.run_time) AS StartTime, 
			   Dateadd(ss, jh.run_duration, 
			   msdb.dbo.Agent_datetime(jh.run_date, jh.run_time)) AS CompletionTime 
		FROM   msdb.dbo.sysjobs AS j 
			   INNER JOIN msdb.dbo.sysjobsteps AS js 
			   ON js.job_id = j.job_id 
			   INNER JOIN msdb.dbo.sysjobhistory AS jh 
			   ON jh.job_id = j.job_id 
			   AND jh.step_name = js.step_name 
		WHERE  jh.run_status = 0 
				AND jh.sql_severity > 9 
				AND js.step_name NOT LIKE 'Failure Notification' 
				OR (jh.message LIKE '%failed%' 
					AND (js.step_name LIKE '%subplan%' or js.step_name LIKE '%SSIS%')
					AND js.step_name NOT LIKE 'Failure Notification')
		) je 
WHERE  run_time >= (SELECT TOP 1 jh.run_time 
					FROM   msdb.dbo.sysjobs AS j 
						   INNER JOIN msdb.dbo.sysjobsteps AS js 
						   ON js.job_id = j.job_id 
						   INNER JOIN msdb.dbo.sysjobhistory AS jh 
						   ON jh.job_id = j.job_id 
						   AND jh.step_name = js.step_name 
					WHERE  jh.run_status = 0 
						   AND jh.sql_severity > 9 
						   AND js.step_name NOT LIKE 'Failure Notification' 
						   OR (jh.message LIKE '%failed%' 
							   AND (js.step_name LIKE '%subplan%' or  js.step_name LIKE '%SSIS%')
							   AND js.step_name NOT LIKE 'Failure Notification') 
					ORDER  BY Dateadd(ss, jh.run_duration, 
							  msdb.dbo.Agent_datetime(jh.run_date, jh.run_time)) DESC, 
							  js.step_id DESC) 
		AND run_date >= (SELECT TOP 1 jh.run_date 
						FROM   msdb.dbo.sysjobs AS j 
							   INNER JOIN msdb.dbo.sysjobsteps AS js 
							   ON js.job_id = j.job_id 
							   INNER JOIN msdb.dbo.sysjobhistory AS jh 
							   ON jh.job_id = j.job_id 
							   AND jh.step_name = js.step_name 
						WHERE  jh.run_status = 0 
							   AND jh.sql_severity > 9 
							   AND js.step_name NOT LIKE 'Failure Notification' 
							   OR (jh.message LIKE '%failed%' 
								   AND (js.step_name LIKE '%subplan%' or  js.step_name LIKE '%SSIS%')
								   AND js.step_name NOT LIKE 'Failure Notification') 
						ORDER BY Dateadd(ss, jh.run_duration,
						msdb.dbo.Agent_datetime(jh.run_date, jh.run_time)) DESC, 
                        js.step_id DESC) 
ORDER BY Dateadd(ss, je.run_duration, 
		 msdb.dbo.Agent_datetime(je.run_date, je.run_time)) DESC, 
	     je.step_id DESC

DELETE FROM #FailedJobs 
WHERE CompletionTime > (SELECT MIN(CompletionTime) FROM #FailedJobs)

DECLARE @JobName VARCHAR(MAX) = (SELECT [Name] FROM #FailedJobs)
DECLARE @StepName VARCHAR(MAX) = (SELECT step_name FROM #FailedJobs)

IF @@RunID IS NOT NULL 
BEGIN
	SET @JobName = 'CUSTOM RUN ID IN USE, JOB NAME NOT AVAILABLE'
	SET @StepName = 'CUSTOM RUN ID IN USE, JOB STEP NOT AVAILABLE'
END


CREATE TABLE #FailTimes
(
ErrorLocation varchar (500),
ErrorTime datetime,
IsMostRecent int,
) 

--1: Find Most Recent Errors

--A: Find Most Recent System Error, store for later
SELECT TOP 1 *  INTO #SystemErrors FROM  (
											SELECT jh.instance_id, 
										    j.NAME, 
										    js.step_name, 
										    jh.sql_severity, 
										    jh.message, 
										    jh.run_date, 
										    jh.run_time, 
										    jh.run_duration, 
										    js.step_id, 
										    js.command,
										    js.database_name, 
										    msdb.dbo.Agent_DATETIME(jh.run_date, jh.run_time)  AS StartTime, 
										    DATEADD(ss, (( jh.run_duration / 10000 * 3600 + ( jh.run_duration / 100 )%100 * 60 + jh.run_duration%100 )), msdb.dbo.Agent_DATETIME(jh.run_date, jh.run_time)) AS CompletionTime 
									        FROM   msdb.dbo.sysjobs AS j 
									        	   INNER JOIN msdb.dbo.sysjobsteps AS js 
									        	   ON js.job_id = j.job_id 
									        	   INNER JOIN msdb.dbo.sysjobhistory AS jh 
									        	   ON jh.job_id = j.job_id 
									        	   AND jh.step_name = js.step_name 
									        WHERE  jh.run_status = 0
										    AND js.step_name <> 'Failure Notification' 
										    OR 
											( 
												jh.message LIKE '%failed%' 
												AND ( 
													      js.step_name LIKE '%subplan%' 
													      OR js.step_name LIKE '%SSIS%' 
													  ) 
												AND js.step_name <> 'Failure Notification' 
											)					
										 )je 
WHERE je.message NOT LIKE '%taskqueue%'
AND je.message NOT LIKE '%Executed as user:%Job%returned with an error.%'
ORDER  BY je.completiontime DESC, 
		  je.step_id DESC 

--B: Save time of SysFail
INSERT INTO #FailTimes (ErrorLocation, ErrorTime, IsMostRecent)
VALUES ('System', (SELECT CompletionTime FROM #SystemErrors), 0)

--C: Find Most Recent Strata Fail. Strata Fails located in either TaskQueue or QAResults

--C1: Find QA Results Tables on server
CREATE TABLE #QADBs
(
ID INT IDENTITY (1,1),
name VARCHAR (500),
HasQAresults INT,
TPSRunID INT,
MaxFailTime DATETIME 
)

INSERT INTO #QADBs ([name], HasQAResults, TPSRunID, MaxFailTime) 
SELECT [name], HasQAResults = 0, TPSRunID = NULL, MaxFailTime = NULL FROM sys.databases

DECLARE @DBname VARCHAR(500) = (SELECT [name] FROM #QADBs WHERE ID = 1)
DECLARE @count int = 1

WHILE (@count <= (SELECT MAX(ID) FROM #QADBs))
BEGIN

	SET @sql = 
	'
	IF (
			SELECT count(*) FROM ' + @DBname + '.dbo.sysobjects 
			WHERE name = ''tblQAResults''
	   ) > 0
		BEGIN 
			UPDATE #QADBs 
			SET HasQAResults = 1 
			WHERE name = ''' + @DBname + '''

			UPDATE #QADBs 
			SET TPSRunID = CASE WHEN ' + isNULL(@@RunID, '''NULL''') + ' = ''NULL'' THEN 
							( 
								SELECT TOP 1 TPSRunID FROM ' + @DBname + '.AGD.tblQAResults
								WHERE IsFailure = 1 
								ORDER BY CONVERT(DATETIME, insertdate) DESC
							)
							ELSE ' + isNULL(@@RunID, '''NULL''') + ' END				
				,MaxFailTime = (
								SELECT TOP 1 InsertDate FROM ' + @DBname + '.AGD.tblQAResults 
								WHERE IsFailure = 1
								and TPSRunId = CASE WHEN ' + isNULL(@@RunID, '''NULL''') + ' <> ''NULL'' THEN ' + isNULL(@@RunID, '''NULL''') + '
								ELSE (SELECT TOP 1 TPSrunid FROM ' + @DBname + '.AGD.tblQAResults
								WHERE IsFailure = 1 order by CONVERT(DATETIME, InsertDate) DESC)
								END
								ORDER BY CONVERT(DATETIME, insertdate) DESC
								)  
			WHERE name = ''' + @DBname + '''
		END
	'
	EXEC (@sql)

	SET @count = @count + 1
	SET @DBname = (
				   SELECT [name] FROM #QADBs 
				   WHERE ID = @count
				  )
END

--C2: Save time of most recent QA Error
INSERT INTO #FailTimes (ErrorLocation, ErrorTime, IsMostRecent)
VALUES ('QA', (SELECT MAX(MaxFailTime) FROM #QADBs), 0) 

--C3: Save time of most recent TaskQueue Error
INSERT INTO #FailTimes (ErrorLocation, ErrorTime, IsMostRecent)
VALUES ('TQ', (
				SELECT TOP (1) CONVERT(DATETIME, EndTime) AS EndTime FROM [TPS_DBA].[dbo].[tblTaskQueue]
				WHERE ErrorMessage is not null 
				and RunId = CASE WHEN @@RunID IS NOT NULL THEN @@RunID
				ELSE (SELECT TOP 1 runid FROM [TPS_DBA].[dbo].[tblTaskQueue]
				WHERE ErrorMessage is not null order by CONVERT(DATETIME, StartTime) DESC)
				END
				ORDER BY CONVERT(DATETIME, starttime) DESC
			   ), 0) 
			--   select * from tps_dba.dbo.tblTaskQueue where runid = '27842'
--D: Set most recent error flag
IF @@RunID IS NOT NULL
BEGIN
	UPDATE #FailTimes 
	SET IsMostRecent = 1
	WHERE Errortime = (SELECT MAX(ErrorTime) FROM  #FailTimes WHERE ErrorLocation in ('QA', 'TQ'))
END
ELSE
BEGIN
	UPDATE #FailTimes 
	SET IsMostRecent = 1
	WHERE Errortime = (SELECT MAX(ErrorTime) FROM #FailTimes)
END

--2: Return most recent error -----------------------------------------------------------------------------------------------------------------------------------

--B: QA Error
IF (
		SELECT ErrorLocation 
		FROM #FailTimes 
		WHERE IsMostRecent = 1
	) = 'QA'

BEGIN
	--B1: QAResults
	SET @DBname = (
					  SELECT TOP 1 name FROM #QADBs 
					  ORDER BY MaxFailTime DESC
				  )
	SET @sql = 
	'
		SELECT b.*, a.Result, a.DataDate, a.InsertDate as ResultInsertDate INTO ##QAresults FROM ' + @DBname + '.AGD.tblQAResults a
		JOIN ' + @DBname + '.AGD.tblQAquery b
		ON a.TPSQueryID = b.TPSQueryID
		WHERE a.TPSRunID = CASE WHEN ' + isNULL(@@RunID, '''NULL''') + '  = ''NULL'' THEN  
		(
			SELECT TPSRunID FROM #QADBs 
			WHERE name = ''' + @DBname + '''
		) 
		ELSE ' + isNULL(@@RunID, '''NULL''') + '  END
		AND a.isfailure = 1
	'
	EXEC (@sql)

	--B2: DataRun
	SET @sql = 
	'
		SELECT * INTO ##DataRun FROM ' + @DBname + '.agd.tblMdDataRun
		WHERE tpsscenariotypeid = 
			(
				SELECT TOP 1 TPSScenarioTypeID FROM ' + @DBname + '.AGD.tblQAResults 
				WHERE TPSRunID = CASE WHEN ' + isNULL(@@RunID, '''NULL''') + '  = ''NULL'' THEN 
				(
					SELECT TPSRunID FROM #QADBs 
					WHERE name = ''' + @DBname + '''
				) 
				ELSE ' + isNULL(@@RunID, '''NULL''') + '  END
				AND isfailure = 1
			)
		ORDER BY EXECOrder asc
	'
	EXEC (@sql)
END

--C: TaskQueue Error
IF (
		SELECT ErrorLocation FROM #FailTimes 
		WHERE IsMostRecent = 1
	) = 'TQ'
BEGIN
	IF @@RunID IS NULL
		BEGIN
			SET @DBname = 
				(
					SELECT TOP 1 TPS_DBA.dbo.udfGetArgument(Arguments, 'PROCESSINGDB') FROM [TPS_DBA].[dbo].[tblTaskQueue]
					WHERE statusid = 3
					AND ErrorMessage <> 'A Task in parallel grouping has failed.  This task will not be EXECuted and is being marked as Failed'
					ORDER BY CONVERT(DATETIME, starttime) DESC
				)
		END
	ELSE
		BEGIN
			SET @DBname =
				(
					SELECT TOP 1 TPS_DBA.dbo.udfGetArgument(Arguments, 'PROCESSINGDB') FROM [TPS_DBA].[dbo].[tblTaskQueue]
					WHERE statusid = 3
					AND ErrorMessage <> 'A Task in parallel grouping has failed.  This task will not be EXECuted and is being marked as Failed'
					AND RunId = @@RunID
					ORDER BY CONVERT(DATETIME, starttime) DESC
				)
		END

	SELECT * into #RunAndScenID FROM 
		(
			SELECT TOP (1) NULLIF(TPS_DBA.dbo.udfGetArgument(Arguments,'SCENARIOID'),'') AS ScenarioType, 
			CASE WHEN @@RunID IS NULL THEN RunID ELSE @@RunID END as RunID
			FROM [TPS_DBA].[dbo].[tblTaskQueue]
			WHERE ErrorMessage is not null 
			and RunId = CASE WHEN @@RunID IS NOT NULL THEN @@RunID
			ELSE (SELECT TOP 1 runid FROM [TPS_DBA].[dbo].[tblTaskQueue]
			WHERE ErrorMessage is not null order by CONVERT(DATETIME, StartTime) DESC)
			END
			ORDER BY CONVERT(DATETIME, starttime) DESC
		) as TaskIDs

	--C1: TaskQueue	
	SELECT Id, ParentID, TaskID, Arguments, StatusID, cast(convert(datetime, starttime) as nvarchar) as StartTime, cast(convert(datetime, EndTime) as nvarchar) as EndTime, ErrorMessage, Requester, RunId, DataDate, NULLIF(TPS_DBA.dbo.udfGetArgument(Arguments,'DATAFEEDID'),'') as datafeedID INTO #TaskQueue FROM [TPS_DBA].[dbo].[tblTaskQueue] 
			WHERE runid = (SELECT RunId FROM #RunAndScenID)
			and ErrorMessage is not null
			order by convert(datetime, starttime) desc

	ALTER TABLE #TaskQueue 
	ADD TPSscenariotypeID int

	UPDATE #TaskQueue set TPSscenariotypeID = (SELECT scenariotype from #RunAndScenID) 
	
	--C1: AGD.tblMdDatafeedImportLogError
    SET @sql =
        '
         WITH ImportLogError (RowNumber, RunId, ImportID, ErrorMessage)
            AS
            (
                SELECT
                    ROW_NUMBER() OVER(ORDER BY InsertDate ASC) as Row#, RunID, ImportID,  ErrorMessage
                    FROM ' + @DBname + '.agd.tblMddatafeedimportlogError
                    WHERE RunId = (SELECT RunId FROM #RunAndScenID)

            )
            ,

             ImportLog (RowNumber, RunID, ImportID, TpsScenarioTypeID, TPSDatafeedID, ImportedFileName, ImportSucceeded, RecordsLoaded, TaskQueueID)
            AS
            (
                SELECT
                    ROW_NUMBER() OVER(ORDER BY ImportedDate ASC) as Row#, a.RunID, a.ImportID, a.TpsScenarioTypeID, a.TPSDatafeedID, a.ImportedFileName, a.ImportSucceeded, a.RecordsLoaded, a.TaskQueueID
                    FROM ' + @DBname + '.agd.tblMddatafeedimportlog a
                    JOIN ' + @DBname + '.agd.tblmddatafeed b
                    on a.TPSdatafeedid = b.TPSDataFeedId
					JOIN ImportLogError c
					on a.Importid = c.ImportId
                    where
                    a.ImportSucceeded = ''N''
                    AND a.RunID = (SELECT RunId FROM #RunAndScenID)

            )
            SELECT RunID, ImportID, TPSScenarioTypeID, TPSDatafeedId, ErrorMessage, ImportedFileName, RecordsLoaded, TaskQueueID INTO ##ImportlogError FROM
            (
                select b.RunID, b.ImportID, b.TPSScenarioTypeID, b.TPSDatafeedID, a.ErrorMessage, b.ImportedFileName, b.RecordsLoaded, b.TaskQueueID from ImportLogError a
                join ImportLog b
                on a.RowNumber = b.RowNumber
                JOIN ' + @DBname + '.[AGD].[tblMdDatafeed] c
                ON b.TPSDatafeedid = c.TPSdatafeedid
                        WHERE a.runid =
                        (
                            SELECT RunId FROM #RunAndScenID
                        )
                        AND b.ImportSucceeded = ''N''
						AND (ISNULL(c.IgnoreFileNotFound, 0) = 0 OR (c.IgnoreFileNotFound = 1 AND a.errormessage not like ''File Not Found%''))
            ) IMLog
        '
    EXEC (@sql)

	SET @sql = 
	'SELECT ' + @DBname + '.AGD.udfReplaceSettingNameInString([datafeedlocation]) as ExactDataFeedLocation, * INTO ##DataFeed 
		FROM ' + @DBname + '.agd.tblmddatafeed 
		WHERE tpsdatafeedid in 
			(
				SELECT TPSDatafeedID FROM ##ImportLogError
			)
	'
	EXEC (@sql)



	SET @sql =	
		'SELECT ' + @DBname + '.AGD.udfReplaceSettingNameInString([Password]) as ExactPassword, ' + @DBname + '.AGD.udfReplaceSettingNameInString([Username]) as ExactUsername, ' + @DBname + '.AGD.udfReplaceSettingNameInString([URL]) as ExactURL, * INTO ##DataFeedDownload FROM ' + @DBname + '.agd.tblmddatafeeddownload
			WHERE tpsdatafeedid in 
			(
				SELECT TPSDatafeedID FROM ##ImportLogError
			)
		'
	EXEC (@sql)


	--C5: SalesForceOperationLog
	SET @sql = 
		'SELECT * INTO ##SFerror FROM 
			(
				SELECT * FROM ' + @DBname + '.[AGD].[tblSalesforceOperationLog]
					WHERE runid = 
						(
							SELECT RunId FROM #RunAndScenID
						)
						AND error <> ''''
						AND error IS NOT NULL
			) AS SF
		'
	EXEC (@sql)

	DECLARE @TPSScenarioTypeID VARCHAR(50) = (SELECT ScenarioType FROM #RunAndScenID)
	--C7: DataRun
	SET @sql = 
	'SELECT * INTO ##DataRun FROM ' + @DBname + '.agd.tblMdDataRun
		WHERE TPSScenarioTypeID = '+ @TPSScenarioTypeID +'
		ORDER BY EXECOrder asc
	'
	EXEC (@sql)

	--DROP TABLE #RunAndScenID
	--DROP TABLE ##datafeedID
END
		
IF (
		SELECT ErrorLocation FROM #FailTimes 
		WHERE IsMostRecent = 1
	) = 'System'
	BEGIN
		INSERT INTO #ErrorResults (ServerName, JobName, StepName, SystemError, SystemCommand, DatabaseName, TaskStartTime, TaskEndTime, RunID)
		SELECT @@SERVERNAME, @JobName, @StepName, [message], [command], [database_name], [StartTime], [CompletionTime], 'N/A'
        from #SystemErrors
	END

IF (
		SELECT ErrorLocation 
		FROM #FailTimes 
		WHERE IsMostRecent = 1
	) = 'QA'
	BEGIN
		INSERT INTO #ErrorResults 
		(ServerName, 
		JobName, 
		StepName, 
		DatabaseName, 
		Datadate,
		ScenarioTypeID,
		QAqueryID,
		QAresult,
		ExpectedQAresult,
		QueryDescription,
		QAquery,
		FailThreshold,
		QAinsertDate)
		select @@SERVERNAME, @JobName, @StepName, @DBname, DataDate, TPSScenarioTypeID, TPSQueryID, Result, ExpectedResult, QueryDescription, Query, FailThreshold, ResultInsertDate 
		from ##QAresults
	END
IF (
		SELECT ErrorLocation FROM #FailTimes 
		WHERE IsMostRecent = 1
	) = 'TQ'
	BEGIN
		INSERT INTO #ErrorResults 
		(ServerName, 
		JobName, 
		StepName, 
		DatabaseName, 
		ScenarioTypeID, 
		TaskQueueID, 
		TaskStartTime, 
		TaskEndTime, 
		TaskQueueError, 
		RunID, 
		Datadate, 
		ImportID, 
		FileDate, 
		ImportTableName, 
		ImportedFileName,
		DatafeedID, 
		RecordsLoaded, 
		ImportErrorMessage, 
		SFobject, 
		SFid, 
		SFerror,
		SFTPpath, 
		SFTPUsername,
		SFTPpassword,
		ChildFileMask, 
		IsZipFile, 
		DataFeedLocation, 
		DataFeedName, 
		DataFeedDescription, 
		LoadOrder, 
		StartLine, 
		DataFeedTypeID, 
		Active, 
		AppendToTable, 
		Delimiter, 
		MaxColumns, 
		Worksheets, 
		TaskType, 
		IgnoreFileNotFound, 
		DropTable)
		select @@SERVERNAME, @JobName, @StepName, a.Requester, a.TPSscenariotypeID, 
		a.Id, a.StartTime, a.EndTime, a.ErrorMessage, a.RunId, a.DataDate,
		b.importId, d.filedate, d.importtablename, b.ImportedFileName, d.TPSDatafeedID, b.RecordsLoaded, 
		b.ErrorMessage, c.Object, c.Salesforceid, c.error, e.ExactURL, e.ExactUsername, e.ExactPassword, d.ChildFileMask, d.IsZipFile, 
		d.ExactDataFeedLocation, d.DataFeedName, d.DataFeedDescription, d.LoadOrder, 
		d.StartLine, d.DataFeedTypeID, d.Active, d.AppendToTable, d.delimiter, 
		d.MaxColumns, d.Worksheets, d.TaskType, d.IgnoreFileNotFound, 
		d.DropTable  from #TaskQueue a
		LEFT JOIN ##ImportlogError b
		on a.RunID = b.RunID
		--and a.datafeedID = b.tpsdatafeedID
		LEFT JOIN ##SFerror c
		on a.RunId = c.RunID
		LEFT JOIN ##datafeed d
		on b.TPSdatafeedid = d.tpsdatafeedid
		LEFT JOIN ##DataFeedDownLoad e
		on b.TPSdatafeedid = e.tpsdatafeedid
	END
	DECLARE @ID int = (SELECT ISNULL(MAX(errorID), 0) FROM dbo.ErrorResults) + 1
	INSERT INTO TPS_DBA.dbo.ErrorResults SELECT *, JiraTicket = NULL, errorID = @ID from #ErrorResults
END
GO

