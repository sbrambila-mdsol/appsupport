USE MSDB 

SELECT TOP 1 je.NAME, 
				 je.step_name
	FROM   (SELECT jh.instance_id, 
				   j.NAME, 
				   js.step_name, 
				   jh.sql_severity, 
				   jh.message, 
				   jh.run_date, 
				   jh.run_time, 
				   jh.run_duration, 
				   js.step_id, 
				   msdb.dbo.Agent_datetime(jh.run_date, jh.run_time) AS StartTime, 
				   Dateadd(ss, ((jh.run_duration/10000*3600 + (jh.run_duration/100)%100*60 + jh.run_duration%100)), msdb.dbo.Agent_datetime(jh.run_date, 
												jh.run_time)) 
																	 AS 
				   CompletionTime 
			FROM   msdb.dbo.sysjobs AS j 
				   INNER JOIN msdb.dbo.sysjobsteps AS js 
						   ON js.job_id = j.job_id 
				   INNER JOIN msdb.dbo.sysjobhistory AS jh 
						   ON jh.job_id = j.job_id 
							  AND jh.step_name = js.step_name 
			WHERE  jh.run_status = 0 
				   --AND jh.sql_severity > 9 
				   AND js.step_name <> 'Failure Notification'
					OR ( jh.message LIKE '%failed%' 
						 AND (js.step_name LIKE '%subplan%' 
						 or  js.step_name LIKE '%SSIS%')
						 AND js.step_name <> 'Failure Notification' ))je 
	ORDER  BY je.CompletionTime
			  DESC, 
			  je.step_id DESC
    
IF OBJECT_ID('tempdb.dbo.#FailTimes', 'U') IS NOT NULL
BEGIN 
	DROP TABLE #FailTimes
END
		

IF OBJECT_ID('tempdb.dbo.#SystemErrors', 'U') IS NOT NULL
BEGIN 
	DROP TABLE #SystemErrors
END

IF OBJECT_ID('tempdb.dbo.#QADBs', 'U') IS NOT NULL
BEGIN 
	DROP TABLE #QADBs
END

IF OBJECT_ID('tempdb.dbo.#RunAndScenID', 'U') IS NOT NULL
BEGIN 
	DROP TABLE #RunAndScenID
END

IF OBJECT_ID('tempdb.dbo.##ImportLogError', 'U') IS NOT NULL
BEGIN 
	DROP TABLE ##ImportLogError
END

IF OBJECT_ID('tempdb.dbo.##SFError', 'U') IS NOT NULL
BEGIN 
	DROP TABLE ##SFError
END

IF OBJECT_ID('tempdb.dbo.#ErrorInfo', 'U') IS NOT NULL
BEGIN 
	DROP TABLE #ErrorInfo
END
    
    CREATE TABLE #FailTimes
(
ErrorLocation VARCHAR(500),
ErrorTime DATETIME,
IsMostRecent INT,
)

DECLARE @sql VARCHAR(max)

IF (SELECT SettingValue from TPS_DBA.dbo.tblServerSetting where SettingName like 'Version%') LIKE '3.%'
BEGIN

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
AND je.message NOT LIKE '%executed as user:%Job%returned with an error.%'
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
		 IF
			(	
				SELECT SettingValue FROM ' + @DBname + '.AGD.tblMdSetting 
				WHERE SETTINGNAME LIKE ''ContinueOnFailQA''
			) = 0
			BEGIN
				UPDATE #QADBs 
				SET HasQAResults = 1 
				WHERE name = ''' + @DBname + '''

				UPDATE #QADBs 
				SET TPSRunID = (
									SELECT TOP 1 TPSRunID FROM ' + @DBname + '.AGD.tblQAResults
									WHERE IsFailure = 1 
									ORDER BY CONVERT(DATETIME, insertdate) DESC
							   ),
					MaxFailTime = (
									SELECT TOP 1 InsertDate FROM ' + @DBname + '.AGD.tblQAResults 
									WHERE IsFailure = 1 
									ORDER BY CONVERT(DATETIME, insertdate) DESC
								  )  
				WHERE name = ''' + @DBname + '''
			END
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
				ORDER BY CONVERT(DATETIME, starttime) DESC
			   ), 0) 

--D: Set most recent error flag
UPDATE #FailTimes 
SET IsMostRecent = 1 
WHERE Errortime = (SELECT MAX(ErrorTime) FROM #FailTimes)

--2: Return most recent error -----------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #ErrorInfo
(
	Scenario VARCHAR(500),
	DFid VARCHAR(500),
	DB VARCHAR(500),
	SP VARCHAR(max),
	Error VARCHAR(max)
)

--A: System Error
IF (
		SELECT ErrorLocation FROM #FailTimes 
		WHERE IsMostRecent = 1
	) = 'System'

BEGIN
	INSERT INTO #ErrorInfo (Scenario, DFid, DB, SP, Error)
	SELECT 'N/A', 'N/A', [database_name],[command], [message] FROM #SystemErrors

	SELECT DISTINCT * FROM #ErrorInfo	
END

DROP TABLE #SystemErrors

--B: QA Error
IF (SELECT ErrorLocation FROM #FailTimes WHERE IsMostRecent = 1) = 'QA'
BEGIN
	SET @DBname = (
					  SELECT TOP 1 name FROM #QADBs 
					  ORDER BY MaxFailTime DESC
				  )
	SET @sql = 
	'
	INSERT INTO #ErrorInfo (Scenario, DFid, DB, SP, Error)
	SELECT TPSScenariotypeID, TPSQueryID, '''+ @DBname + ''', ''N/A'', Query FROM ' + @DBname + '.AGD.tblQAResults 
	WHERE TPSRunID = (
									SELECT TPSRunID FROM #QADBs 
									WHERE name = ''' + @DBname + '''
					 )
    AND isfailure = 1
	'
	EXEC (@sql)

	SELECT DISTINCT * FROM #ErrorInfo
END

DROP TABLE #QADBs

--C: TaskQueue Error
IF (
		SELECT ErrorLocation FROM #FailTimes 
		WHERE IsMostRecent = 1
	) = 'TQ'
BEGIN
	DECLARE @ErrorPosted int = 0

	SET @DBname = 
		(
			SELECT TOP 1 TPS_DBA.dbo.udfGetArgument(Arguments, 'PROCESSINGDB') FROM [TPS_DBA].[dbo].[tblTaskQueue]
			WHERE statusid = 3
			AND ErrorMessage <> 'A Task in parallel grouping has failed.  This task will not be EXECuted and is being marked as Failed'
			ORDER BY CONVERT(DATETIME, starttime) DESC
		)

	SELECT * INTO #RunAndScenID FROM 
		(
			SELECT TOP (1) NULLIF(TPS_DBA.dbo.udfGetArgument(Arguments,'SCENARIOID'),'') AS ScenarioType, RunId FROM [TPS_DBA].[dbo].[tblTaskQueue]
			WHERE ErrorMessage is not null 
			ORDER BY CONVERT(DATETIME, starttime) DESC
		) AS TaskIDs
	--C1: AGD.tblMdDatafeedImportLogError
	SET @sql = 
		'
		 WITH ImportLogError (RowNumber, RunId, ErrorMessage)
			AS
			(
				SELECT
					ROW_NUMBER() OVER(ORDER BY InsertDate ASC) as Row#, RunID, ErrorMessage
					FROM ' + @DBname + '.agd.tblMddatafeedimportlogError
					WHERE RunId = (SELECT RunId FROM #RunAndScenID)

			)
			,

			 ImportLog (RowNumber, RunID, TpsScenarioTypeID, TPSDatafeedID, ImportSucceeded)
			AS
			(
				SELECT
					ROW_NUMBER() OVER(ORDER BY ImportedDate ASC) as Row#, RunID, a.TpsScenarioTypeID, a.TPSDatafeedID, ImportSucceeded
					FROM ' + @DBname + '.agd.tblMddatafeedimportlog a
					JOIN ' + @DBname + '.agd.tblmddatafeed b
					on a.TPSdatafeedid = b.TPSDataFeedId
					where
					a.ImportSucceeded = ''N''
					AND b.IgnoreFileNotFound = 0
					AND RunID = (SELECT RunId FROM #RunAndScenID)

			)
			SELECT TPSScenarioTypeID, TPSDatafeedId, ErrorMessage INTO ##ImportLogError FROM 
			(
				select b.TPSScenarioTypeID, b.TPSDatafeedID, a.ErrorMessage from  ImportLogError a
				join ImportLog b
				on a.RowNumber = b.RowNumber
				JOIN ' + @DBname + '.[AGD].[tblMdDatafeed] c 
				ON b.TPSDatafeedid = c.TPSdatafeedid
						WHERE a.runid = 
						(
							SELECT RunId FROM #RunAndScenID
						)
						AND b.ImportSucceeded = ''N''
						AND c.IgnoreFileNotFound = 0
			) IMLog
		'
	EXEC (@sql)

	IF 	(
			SELECT COUNT(*) FROM ##ImportLogError
		) > 0
	BEGIN
		INSERT INTO #ErrorInfo (Scenario, DFid, DB, SP, Error)
		SELECT TPSScenarioTypeID, TPSDatafeedId, @DBname, 'N/A', ErrorMessage FROM ##ImportLogError

		SET @sql = 
		'
			UPDATE #ErrorInfo 
			SET SP = (
						SELECT TOP 1 EXECProcess FROM ' + @DBname + '.agd.tblmddatarunlog
						WHERE TaskQueueID = (
												SELECT TOP 1 ID FROM TPS_DBA.dbo.tblTaskQueue 
												WHERE RunId = (
																	SELECT RunId FROM #RunAndScenID
															  ) 
												AND ErrorMessage IS NOT null
											)
					 )
		'
		EXEC (@sql)

		SELECT DISTINCT * FROM #ErrorInfo

		SET @ErrorPosted = 1
	END

	DROP TABLE ##ImportLogError

	--C2: AGD.tblMdSalesforceOperationLog
	SET @sql = 
		'SELECT * INTO ##SFError FROM 
			(
				SELECT error, DatafeedId FROM ' + @DBname + '.[AGD].[tblSalesforceOperationLog]
					WHERE runid = 
						(
							SELECT RunId FROM #RunAndScenID
						)
						AND error <> ''''
						AND error IS NOT NULL
			) AS SF
		'
	EXEC (@sql)

	IF (
			SELECT COUNT(*) FROM ##SFError
		) > 0
	BEGIN 
		INSERT INTO #ErrorInfo (Scenario, DFid, DB, SP, Error)
		SELECT 'N/A', DatafeedId, @DBname, 'N/A', error FROM ##SFError
		
		UPDATE #ErrorInfo 
		SET Scenario = (
							SELECT ScenarioType FROM #RunAndScenID
						)
		SET @sql = 
		'
			UPDATE #ErrorInfo 
			SET SP = (
						SELECT TOP 1 EXECProcess FROM ' + @DBname + '.agd.tblmddatarunlog 
						WHERE TaskQueueID = (
												SELECT TOP 1 ID FROM TPS_DBA.dbo.tblTaskQueue 
												WHERE RunId = (
																SELECT RunId FROM #RunAndScenID
															  ) 
												AND ErrorMessage IS NOT NULL
											)
					)
		'
		EXEC (@sql)

		SELECT DISTINCT * FROM #ErrorInfo

		SET @ErrorPosted = 1
	END

	DROP TABLE ##SFError

	--C3: dbo.tblTaskQueue
	IF (@ErrorPosted = 0) 
	BEGIN
		INSERT INTO #ErrorInfo (Scenario, DFid, DB, SP, Error)
		SELECT 'N/A', 'N/A', @DBName, 'N/A', ErrorMessage FROM [TPS_DBA].[dbo].[tblTaskQueue] 
		WHERE runid = 
			(
				SELECT RunId FROM #RunAndScenID
			)
		AND ErrorMessage IS NOT NULL

		UPDATE #ErrorInfo 
		SET Scenario = (
							SELECT ScenarioType FROM #RunAndScenID
						)

		SET @sql = 
		'
			UPDATE #ErrorInfo 
			SET SP = (
					 	SELECT TOP 1 EXECProcess FROM ' + @DBname + '.agd.tblmddatarunlog 
					 	WHERE TaskQueueID = (
					 							SELECT TOP 1 ID FROM TPS_DBA.dbo.tblTaskQueue 
					 							WHERE RunId = (
					 												SELECT RunId FROM #RunAndScenID
					 										  ) 
					 							AND ErrorMessage IS NOT NULL
					 						 )
					 )
		'
		EXEC (@sql)

		SELECT DISTINCT * FROM #ErrorInfo

	END

	DROP TABLE #RunAndScenID

END

DROP TABLE #FailTimes

DROP TABLE #ErrorInfo


END
ELSE 
declare @sql2 varchar(10) = '' 
GO

IF (SELECT SettingValue from TPS_DBA.dbo.tblServerSetting where SettingName like 'Version%') LIKE '2.%'
BEGIN 

declare @sql nvarchar(max)

IF OBJECT_ID('tempdb.dbo.#FailTimes', 'U') IS NOT NULL
BEGIN 
	DROP TABLE #FailTimes
END

CREATE TABLE #FailTimes
(
ErrorLocation varchar (500),
ErrorTime datetime,
IsMostRecent int,
)

--1: Find Most Recent Errors in v2 project 
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
WHERE je.message NOT LIKE '%executed as user:%Job%returned with an error.%'
ORDER  BY je.completiontime DESC, 
		  je.step_id DESC 

--B: Save time of SysFail
INSERT INTO #FailTimes (ErrorLocation, ErrorTime, IsMostRecent)
VALUES ('System', (SELECT CompletionTime FROM #SystemErrors), 0)

--C: Find Most Recent Strata Fail. Strata Fails located in either TaskQueue or QAResults

--C1: Find failed database on server
IF OBJECT_ID('tempdb.dbo.#DrDBs', 'U') IS NOT NULL
BEGIN 
	DROP TABLE #DrDBs
END

CREATE TABLE #DrDBs
(
ID INT IDENTITY (1,1),
name VARCHAR (500),
HasDataRunLog INT,
TPSRunID INT,
MaxFailTime DATETIME 
)

INSERT INTO #DrDBs ([name], HasDataRunLog, TPSRunID, MaxFailTime) 
SELECT [name], HasDataRunLog = 0, TPSRunID = NULL, MaxFailTime = NULL FROM sys.databases

DECLARE @DBname VARCHAR(500) = (SELECT [name] FROM #DrDBs WHERE ID = 1)
DECLARE @count int = 1

WHILE (@count <= (SELECT MAX(ID) FROM #DrDBs))
BEGIN
	SET @sql = 
	'
	IF (
			SELECT count(*) FROM ' + @DBname + '.dbo.sysobjects 
			WHERE name = ''tblMdDataRunLog''
	   ) > 0
		BEGIN 
			UPDATE #DrDBs 
			SET HasDataRunLog = 1 
			WHERE name = ''' + @DBname + '''

			UPDATE #DrDBs 
			SET TPSRunID = (
								SELECT TOP 1 TPSRunID FROM ' + @DBname + '.AGD.tblMdDataRunLog
								WHERE InsertDate >= (SELECT StartTime FROM #SystemErrors) AND ErrorMessage IS NOT NULL
								ORDER BY CONVERT(DATETIME, insertdate) DESC
						   ),
				MaxFailTime = (
								SELECT TOP 1 StartTime FROM ' + @DBname + '.AGD.tblMdDataRunLog 
								WHERE InsertDate >= (SELECT StartTime FROM #SystemErrors)
								AND TPSRunId = (SELECT TOP 1 TPSRunID FROM ' + @DBname + '.AGD.tblMdDataRunLog 
								WHERE InsertDate >= (SELECT StartTime FROM #SystemErrors) AND ErrorMessage IS NOT NULL
								ORDER BY CONVERT(DATETIME, insertdate) DESC)
								ORDER BY CONVERT(DATETIME, insertdate) DESC
							  )  
			WHERE name = ''' + @DBname + '''
		END
	'
	EXEC (@sql)
	SET @count = @count + 1
	SET @DBname = (
				   SELECT [name] FROM #DrDBs 
				   WHERE ID = @count
				  )
END

IF OBJECT_ID('tempdb.dbo.#IMErrorLog', 'U') IS NOT NULL
BEGIN 
	DROP TABLE #IMErrorLog
END

CREATE TABLE #IMErrorLog
(
ID INT IDENTITY (1,1),
name VARCHAR (500),
HasDataRunLog INT,
TPSRunID INT,
MaxFailTime DATETIME 
)

SET @DBname = (SELECT TOP 1 NAME FROM #DrDBs WHERE HasDataRunLog IS NOT NULL AND TPSRunID IS NOT NULL AND MaxFailTime = (SELECT MAX(MaxFailTime) FROM #DrDBs) AND MaxFailTime IS NOT NULL)

INSERT INTO #IMErrorLog ([name], HasDataRunLog, TPSRunID, MaxFailTime) 
SELECT [name], HasImportErrorLog = 0, TPSRunID = NULL, MaxFailTime = NULL FROM sys.databases where name = @DBname

SET @sql = 
	'
	IF (
			SELECT count(*) FROM ' + @DBname + '.dbo.sysobjects 
			WHERE name = ''tblMddatafeedimportlogError''
	   ) > 0
		BEGIN 
			UPDATE #IMErrorLog 
			SET HasDataRunLog = 1 
			WHERE name = ''' + @DBname + '''

			UPDATE #IMErrorLog 
			SET TPSRunID = (
								SELECT TOP 1 TPSRunID FROM ' + @DBname + '.AGD.tblMddatafeedimportlogError
								WHERE InsertDate >= (SELECT StartTime FROM #SystemErrors) AND ErrorMessage IS NOT NULL
								ORDER BY InsertDate DESC
						   ),
				MaxFailTime = (
								SELECT TOP 1 InsertDate FROM ' + @DBname + '.AGD.tblMddatafeedimportlogError 
								WHERE InsertDate >= (SELECT StartTime FROM #SystemErrors) AND ErrorMessage IS NOT NULL
								ORDER BY InsertDate DESC
							  )  
			WHERE name = ''' + @DBname + '''
		END
	'
	EXEC (@sql)



--C2: Save time of most recent QA Error
INSERT INTO #FailTimes (ErrorLocation, ErrorTime, IsMostRecent)
VALUES ('DRLog', (SELECT MAX(MaxFailTime) FROM #DrDBs), 0) 

--C3: Save time of most recent ImportLog Error
INSERT INTO #FailTimes (ErrorLocation, ErrorTime, IsMostRecent)
VALUES ('IMLog', (SELECT MAX(MaxFailTime) FROM #IMErrorLog), 0) 



--D: Set most recent error flag
UPDATE #FailTimes 
SET IsMostRecent = 1 
WHERE Errortime = (SELECT MAX(ErrorTime) FROM #FailTimes)

--2: Return most recent error -----------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE #ErrorInfo
(
	Scenario VARCHAR(500),
	DFid VARCHAR(500),
	DB VARCHAR(500),
	SP VARCHAR(max),
	Error VARCHAR(max)
)

--A: System Error
IF (
		SELECT ErrorLocation FROM #FailTimes 
		WHERE IsMostRecent = 1
	) = 'System'

BEGIN
	INSERT INTO #ErrorInfo (Scenario, DFid, DB, SP, Error)
	SELECT 'N/A', 'N/A', [database_name],[command], [message] FROM #SystemErrors

	SELECT DISTINCT * FROM #ErrorInfo	
END

--DROP TABLE #SystemErrors

--B: DR Error
IF (SELECT ErrorLocation FROM #FailTimes WHERE IsMostRecent = 1) = 'DRLog'
BEGIN
	SET @DBname = (
					  SELECT TOP 1 NAME FROM #DrDBs WHERE HasDataRunLog IS NOT NULL AND TPSRunID IS NOT NULL AND MaxFailTime = (SELECT MAX(MaxFailTime) FROM #DrDBs) AND MaxFailTime IS NOT NULL
				  )
	SET @sql = 
	'
	INSERT INTO #ErrorInfo (Scenario, DFid, DB, SP, Error)
	SELECT TOP 1 TPSScenariotypeID, ''N/A'', '''+ @DBname + ''', ExecProcess, ErrorMessage FROM ' + @DBname + '.AGD.tblMdDataRunLog
		WHERE StartTime >= (SELECT StartTime FROM #SystemErrors) AND ErrorMessage IS NOT NULL
		ORDER BY CONVERT(DATETIME, insertdate) DESC
	'
	EXEC (@sql)

	SELECT DISTINCT * FROM #ErrorInfo
END

--DROP TABLE #DrDBs

--C: IMLog Error
IF (
		SELECT ErrorLocation FROM #FailTimes 
		WHERE IsMostRecent = 1
	) = 'IMLog'
BEGIN

	SET @DBname = ( SELECT TOP 1 NAME FROM #DrDBs WHERE HasDataRunLog IS NOT NULL AND TPSRunID IS NOT NULL AND MaxFailTime = (SELECT MAX(MaxFailTime) FROM #DrDBs) AND MaxFailTime IS NOT NULL)

	IF OBJECT_ID('tempdb.dbo.##ImportLogError', 'U') IS NOT NULL
	BEGIN 
		DROP TABLE ##ImportLogError
	END
	IF OBJECT_ID('tempdb.dbo.#runandscenid', 'U') IS NOT NULL
	BEGIN 
		DROP TABLE #runandscenid
	END
	set @sql = '
				IF OBJECT_ID(''tempdb.dbo.##ImportLogError'', ''U'') IS NOT NULL
				BEGIN 
					DROP TABLE ##ImportLogError
				END
				'
	exec (@sql) 
	SELECT * INTO #RunAndScenID FROM 
		(
			 SELECT TOP 1 TPSRunID as RunId FROM #DrDBs WHERE HasDataRunLog IS NOT NULL AND TPSRunID IS NOT NULL AND MaxFailTime = (SELECT MAX(MaxFailTime) FROM #DrDBs) AND MaxFailTime IS NOT NULL

		) AS TaskIDs
		
	--C1: AGD.tblMdDatafeedImportLogError
	set @sql = 
		'
		 WITH ImportLogError (RowNumber, RunId, ErrorMessage)
			AS
			(
				SELECT
					ROW_NUMBER() OVER(ORDER BY InsertDate ASC) as Row#, RunID, ErrorMessage
					FROM ' + @DBname + '.agd.tblMddatafeedimportlogError
					WHERE RunId = (SELECT RunId FROM #RunAndScenID)

			)
			,

			 ImportLog (RowNumber, RunID, TpsScenarioTypeID, TPSDatafeedID, ImportSucceeded)
			AS
			(
				SELECT
					ROW_NUMBER() OVER(ORDER BY ImportedDate ASC) as Row#, RunID, b.TpsScenarioTypeID, a.TPSDatafeedID, ImportSucceeded
					FROM ' + @DBname + '.agd.tblMddatafeedimportlog a
					JOIN ' + @DBname + '.agd.tblmddatafeed b
					on a.TPSdatafeedid = b.TPSDataFeedId
					where
					a.ImportSucceeded = ''N''
					AND b.IgnoreFileNotFound = 0
					AND RunID = (SELECT RunId FROM #RunAndScenID)

			)
			SELECT TPSScenarioTypeID, TPSDatafeedId, ErrorMessage INTO ##ImportLogError FROM 
			(
				select b.TPSScenarioTypeID, b.TPSDatafeedID, a.ErrorMessage from  ImportLogError a
				join ImportLog b
				on a.RowNumber = b.RowNumber
				JOIN ' + @DBname + '.[AGD].[tblMdDatafeed] c 
				ON b.TPSDatafeedid = c.TPSdatafeedid
						WHERE a.runid = 
						(
							SELECT RunId FROM #RunAndScenID
						)
						AND b.ImportSucceeded = ''N''
						AND c.IgnoreFileNotFound = 0
			) IMLog
		'
	EXEC (@sql)
	
	IF 	(
			SELECT COUNT(*) FROM ##ImportLogError
		) > 0
	BEGIN
		INSERT INTO #ErrorInfo (Scenario, DFid, DB, SP, Error)
		SELECT TPSScenarioTypeID, TPSDatafeedId, @DBname, 'N/A', ErrorMessage FROM ##ImportLogError

		SET @sql = 
		'
			UPDATE #ErrorInfo 
			SET SP = (
						SELECT TOP 1 EXECProcess FROM ' + @DBname + '.agd.tblmddatarunlog
						WHERE TPSRunId = (
										SELECT RunId FROM #RunAndScenID
									  ) 
										AND ErrorMessage IS NOT null
					 )
		'
		EXEC (@sql)
		
		SELECT DISTINCT * FROM #ErrorInfo

	END

	DROP TABLE ##ImportLogError
	DROP TABLE #IMErrorLog

	DROP TABLE #RunAndScenID

END

DROP TABLE #FailTimes

DROP TABLE #ErrorInfo

END