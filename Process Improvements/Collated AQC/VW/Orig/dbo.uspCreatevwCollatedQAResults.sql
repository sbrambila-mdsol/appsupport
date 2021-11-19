USE [tps_dba]
GO

--drop procedure if exists [dbo].[uspCreatevwCollatedQAResults]
--go

IF OBJECT_ID('dbo.uspCreatevwCollatedQAResults') IS NOT NULL 
    BEGIN 
        DROP PROCEDURE dbo.uspCreatevwCollatedQAResults 
    END

/****** Object:  StoredProcedure [dbo].[uspCreatevwCollatedQAResults]    Script Date: 7/15/2019 5:04:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspCreatevwCollatedQAResults]
/*******************************************************************************************
Name:               uspCreatevwCollatedQAResults
Purpose:            Creates a view that UNIONs results from all databases that have tblQAQuery.
Inputs:             None
Author:             Aidan Fennessy 
Created:            13th Jun 2019
History:            Date                Name                Comment
                    13th Jun 2019       Aidan Fennessy      Initial Creation

Copyright:
RunTime:            00:00:00 (HH:MM:SS)

Execution:          EXEC TPS_DBA.dbo.uspCreatevwCollatedQAResults

NOTES:				This procedure will only UNION results from a database if the columns for
					tblQAQuery in that database match the columns of those in the main processing
					database for the customer (which is presumed to be the client name, e.g. Greenwich).

					percent change compared to avg over lookup period plus standard deviation over lookup period. 

					
*******************************************************************************************/

AS
BEGIN
	SET NOCOUNT ON 

	DECLARE @sql nvarchar(max),
	@CreateView nvarchar(max),
	@ClientName nvarchar(max) = CASE WHEN @@SERVERNAME = 'PROARI27DB1' THEN 'ARIAD_PROCESSING_EU_Daily' WHEN @@SERVERNAME = 'PROTSR10DB1' THEN 'TESARO_CONTROLLER' WHEN @@SERVERNAME = 'PROAGN05DB5' THEN 'AGN_MEDICAL' WHEN @@SERVERNAME = 'PRDSHP10DB2' THEN 'RR_Processing' ELSE dbo.udfGetServerSetting('ClientName') END,
	@DBname VARCHAR(500),
	@count int = 1,
	@DatabaseName nvarchar(400),
	@DynSQL nvarchar(MAX) = ''
	
 
	IF OBJECT_ID('tempdb.dbo.##QADBs', 'U') IS NOT NULL
		DROP TABLE #QADBs; 
	--DROP TABLE IF EXISTS #QADBs
	CREATE TABLE #QADBs
	(
	ID INT IDENTITY (1,1),
	name VARCHAR (500),
	HasQAresults INT
	)
	
	INSERT INTO #QADBs ([name], HasQAResults) 
	SELECT [name], HasQAResults = 0 FROM sys.databases where name not like 'report%'
	
	SET @DBname = (SELECT [name] FROM #QADBs WHERE ID = 1)
	
	WHILE (@count <= (SELECT MAX(ID) FROM #QADBs))
	BEGIN
		SET @sql = 
		'
		IF (
				SELECT count(*) FROM ' + @DBname + '.dbo.sysobjects 
				WHERE name = ''tblQAResults''
				AND NOT EXISTS 
				(	
					SELECT 1 FROM [' + @ClientName + '].sys.columns AS c 
				    WHERE [object_id] = OBJECT_ID(N''' + @ClientName + '.agd.'' + QUOTENAME(''tblQAResults''))
				    AND NOT EXISTS
				    (
				      SELECT 1 FROM [' + @DBname + '].sys.columns
				      WHERE [object_id] = OBJECT_ID(N''' + @DBname + '.agd.'' + QUOTENAME(''tblQAResults''))
				      AND name = c.name
				    )
				)
		   ) > 0
			BEGIN 
					UPDATE #QADBs 
					SET HasQAResults = 1 
					WHERE name = ''' + @DBname + '''
			END
		'
		--PRINT @SQL
		EXEC (@sql)
		SET @count = @count + 1
		SET @DBname = (
					   SELECT [name] FROM #QADBs 
					   WHERE ID = @count
					  )
	END
	
	DELETE FROM #QADBs WHERE HasQAResults != 1
	DELETE FROM #QADBs WHERE name like 'dbrestore%'
	--DELETE FROM #QADBs WHERE name like 'ULTRAGENYX'
	
	SELECT * FROM #QADBs

	DECLARE cursor1 CURSOR FOR 
	    select [name]
	    from #QADBs

	OPEN cursor1
	
	FETCH NEXT FROM cursor1 INTO @DatabaseName
	

	WHILE @@FETCH_STATUS = 0
	BEGIN
	    -- Add the select code.
	    Set @DynSQL = @DynSQL + '
    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE ''''ClientName'''') AS Customer,''''' + @DatabaseName + ''''' AS ''''Database'''', 	
	 QueryID = q.TPSQueryID
				, TPSRunID	= qryC.TPSRunID
				, QueryType = ISNULL(q.QueryType, '''''''')
				, QueryName = ISNULL(q.QueryDescription, '''''''')				
				, AlertType = CASE 
									WHEN q.AlertType = ''''WARN'''' AND q.FailThreshold IS NOT NULL THEN ''''Warn/Fail'''' 
									WHEN q.AlertType = ''''WARN'''' AND q.FailThreshold is NULL THEN ''''Warn''''
									WHEN q.AlertType = ''''FAIL'''' THEN ''''Fail''''
									ELSE ''''''''
								END 
				, WarnThreshold = CASE 
										WHEN q.AlertType = ''''WARN'''' THEN CAST(q.PercentOff AS NVARCHAR(10))
										ELSE ''''''''
									END
				, FailThreshold = CASE 
										WHEN q.AlertType = ''''Warn'''' AND q.FailThreshold IS NOT NULL THEN CAST(FailThreshold AS NVARCHAR(10))
										WHEN q.AlertType = ''''Fail'''' THEN CAST(q.PercentOff AS NVARCHAR(10))
										ELSE ''''''''
									END
				, ExpectedResult =  ISNULL(CAST(q.ExpectedResult AS NVARCHAR(50)), '''''''')
				, CurrentDataDate = qryC.Datadate				
				, CurrentResult	=  CASE 
										WHEN QueryResultType = ''''DATE'''' 
											THEN CAST(CAST(CAST(LEFT(qryC.Result, 8) AS VARCHAR(50)) AS DATE) AS VARCHAR(50)) 
											ELSE CAST(qryC.Result AS VARCHAR(50)) 
									END										
				, PriorResult	=  CASE 
										WHEN QueryResultType = ''''DATE'''' 
										THEN 
											CASE 
												WHEN qryP.Result IS NULL THEN '''''''' 
												ELSE CAST(CAST(CAST(LEFT(qryP.Result, 8) AS VARCHAR(50)) AS DATE) AS VARCHAR(50)) END 										
										ELSE CAST(ISNULL(qryP.Result,0) AS VARCHAR(50)) END	
				, PriorDataDate = CAST ( CASE	WHEN qryP.Datadate IS NULL THEN ''''N/a'''' ELSE CAST(convert(varchar, qryP.Datadate, 111) AS varchar) END AS VARCHAR(50)) 			
				, PercentChange	= CAST(	CASE	WHEN (qryP.Result IS NULL OR qryP.Result = 0) AND (qryC.Result IS NULL OR qryC.Result = 0) THEN 0
														WHEN (qryP.Result IS NULL OR qryP.Result = 0) AND qryC.Result <> 0 THEN 100 	
														ELSE (
															CASE WHEN q.QueryResultType = ''''DATE'''' 
																THEN ABS(DATEDIFF(dd, CAST(LEFT(qryP.Result, 8) AS VARCHAR(50)), CAST(LEFT(qryC.Result, 8) AS VARCHAR(50)))) 
																ELSE ABS(100*((qryC.Result - qryP.Result) / qryP.Result)) 
																END)
												END AS DECIMAL(19,4))
				, qryAVG.*
				, qryC.Query
				, Failure	= ISNULL(qryC.IsFailure, 0)
				, Warning = ISNULL(qryC.IsWarning, 0)	
				, qryC.InsertDate															
		FROM	' + @DatabaseName + '.agd.tblQAQuery q
				INNER JOIN (SELECT * FROM ( SELECT DENSE_RANK() over (partition by TPSQueryID order by InsertDate desc) as row_num, * 
        from ' + @DatabaseName + '.agd.tblQAResults  ) AS Queries WHERE row_num = 1) qryC ON
						Q.TPSQueryId = qryC.TPSQueryId
				AND		Q.TPSScenarioTypeId = qryC.TPSScenarioTypeId
				LEFT JOIN (SELECT * FROM ( SELECT DENSE_RANK() over (partition by TPSQueryID order by InsertDate desc) as row_num, * 
        from ' + @DatabaseName + '.agd.tblQAResults  ) AS Queries WHERE row_num = 2) qryP ON
						Q.TPSQueryId = qryP.TPSQueryId
				AND		Q.TPSScenarioTypeId = qryP.TPSScenarioTypeId
				LEFT JOIN (Select TPSQueryID, TPSScenarioTypeId, avg_results = AVG(RESULT), STD_DEV = STDEV(RESULT), LOWER_BOUND = AVG(RESULT) - STDEV(RESULT), UPPER_BOUND = AVG(RESULT) + STDEV(RESULT) FROM ( SELECT DENSE_RANK() over (partition by TPSQueryID order by InsertDate desc) as row_num, * 
        from ' + @DatabaseName + '.agd.tblQAResults  ) AS Queries WHERE row_num <= 10 AND TRY_CAST(InsertDate AS date) > TRY_CAST(DATEADD(month, -3, GETDATE()) AS date) GROUP BY TPSQueryID, TPSScenarioTypeId) qryAVG ON
						Q.TPSQueryId = qryAVG.TPSQueryId
				AND		Q.TPSScenarioTypeId = qryAVG.TPSScenarioTypeId
		WHERE  NOT ( QueryDescription = ''''AgileD run fails'''' --AND qar.Result = CAST(0 AS VARCHAR(50))
		)
		AND qryC.TPSQueryID in 	(	SELECT distinct TPSQueryID from ' + @DatabaseName + '.agd.tblQAResults where TPSQueryID in (SELECT TPSQueryID from ' + @DatabaseName + '.agd.tblQAQuery where Active = 1	)	)
		and TRY_CAST(qryC.InsertDate AS date) > TRY_CAST(DATEADD(month, -3, GETDATE()) AS date)

		' + CHAR(10) + ''

	    FETCH NEXT FROM cursor1
	    INTO @DatabaseName

	    -- If the loop continues, add the UNION ALL statement.
	    If @@FETCH_STATUS = 0
	    BEGIN
	        Set @DynSQL = @DynSQL + '' + CHAR(10) + ' UNION ALL ' + CHAR(10) + CHAR(10) + ''
	    END
	
	END

	CLOSE cursor1
	DEALLOCATE cursor1
	
	--Print @DynSQL
	--exec sp_executesql @DynSQL
	
	IF OBJECT_ID('dbo.vwCollatedQAResults') IS NOT NULL 
    BEGIN 
        DROP VIEW dbo.vwCollatedQAResults 
    END

	--DROP VIEW IF EXISTS [dbo].[vwCollatedQAResults]

	SET @CreateView = 
	'	
	USE TPS_DBA;
	
	EXEC (''
	CREATE VIEW [dbo].[vwCollatedQAResults]

	AS

	' + @DynSQL + '
	'')
	'
	--PRINT @DynSQL
	--PRINT @CreateView
	EXEC (@CreateView)

END

GO
