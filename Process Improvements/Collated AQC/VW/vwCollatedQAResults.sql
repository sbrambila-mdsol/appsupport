USE [TPS_DBA]
GO

/****** Object:  View [dbo].[vwCollatedQAResults]    Script Date: 1/14/2020 1:02:54 PM ******/
DROP VIEW  IF EXISTS [dbo].[vwCollatedQAResults]
GO

/****** Object:  View [dbo].[vwCollatedQAResults]    Script Date: 1/14/2020 1:02:54 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


	CREATE VIEW [dbo].[vwCollatedQAResults]

	AS

	
    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE 'ClientName') AS Customer,'<Customer>' AS 'Database', 	
	 QueryID = q.TPSQueryID
				, TPSRunID	= qryC.TPSRunID
				, QueryType = ISNULL(q.QueryType, '')
				, QueryName = ISNULL(q.QueryDescription, '')				
				, AlertType = CASE 
									WHEN q.AlertType = 'WARN' AND q.FailThreshold IS NOT NULL THEN 'Warn/Fail' 
									WHEN q.AlertType = 'WARN' AND q.FailThreshold is NULL THEN 'Warn'
									WHEN q.AlertType = 'FAIL' THEN 'Fail'
									ELSE ''
								END 
				, WarnThreshold = CASE 
										WHEN q.AlertType = 'WARN' THEN CAST(q.PercentOff AS NVARCHAR(10))
										ELSE ''
									END
				, FailThreshold = CASE 
										WHEN q.AlertType = 'Warn' AND q.FailThreshold IS NOT NULL THEN CAST(FailThreshold AS NVARCHAR(10))
										WHEN q.AlertType = 'Fail' THEN CAST(q.PercentOff AS NVARCHAR(10))
										ELSE ''
									END
				, ExpectedResult =  ISNULL(CAST(q.ExpectedResult AS NVARCHAR(50)), '')
				, CurrentDataDate = qryC.Datadate				
				, CurrentResult	=  CASE 
										WHEN QueryResultType = 'DATE' 
											THEN CAST(CAST(CAST(LEFT(qryC.Result, 8) AS VARCHAR(50)) AS DATE) AS VARCHAR(50)) 
											ELSE CAST(qryC.Result AS VARCHAR(50)) 
									END										
				, PriorResult	=  CASE 
										WHEN QueryResultType = 'DATE' 
										THEN 
											CASE 
												WHEN qryP.Result IS NULL THEN '' 
												ELSE CAST(CAST(CAST(LEFT(qryP.Result, 8) AS VARCHAR(50)) AS DATE) AS VARCHAR(50)) END 										
										ELSE CAST(ISNULL(qryP.Result,0) AS VARCHAR(50)) END	
				, PriorDataDate = CAST ( CASE	WHEN qryP.Datadate IS NULL THEN 'N/a' ELSE CAST(convert(varchar, qryP.Datadate, 111) AS varchar) END AS VARCHAR(50)) 			
				, PercentChange	= CAST(	CASE	WHEN (qryP.Result IS NULL OR qryP.Result = 0) AND (qryC.Result IS NULL OR qryC.Result = 0) THEN 0
														WHEN (qryP.Result IS NULL OR qryP.Result = 0) AND qryC.Result <> 0 THEN 100 	
														ELSE (
															CASE WHEN q.QueryResultType = 'DATE' 
																THEN ABS(DATEDIFF(dd, CAST(LEFT(qryP.Result, 8) AS VARCHAR(50)), CAST(LEFT(qryC.Result, 8) AS VARCHAR(50)))) 
																ELSE ABS(100*((qryC.Result - qryP.Result) / qryP.Result)) 
																END)
												END AS DECIMAL(19,4))
				, qryAVG.*
				, qryC.Query
				, Failure	= ISNULL(qryC.IsFailure, 0)
				, Warning = ISNULL(qryC.IsWarning, 0)	
				, qryC.InsertDate															
		FROM	<Customer>.agd.tblQAQuery q
				INNER JOIN (SELECT * FROM ( SELECT DENSE_RANK() over (partition by TPSQueryID order by InsertDate desc) as row_num, * 
        from <Customer>.agd.tblQAResults  ) AS Queries WHERE row_num = 1) qryC ON
						Q.TPSQueryId = qryC.TPSQueryId
				AND		Q.TPSScenarioTypeId = qryC.TPSScenarioTypeId
				LEFT JOIN (SELECT * FROM ( SELECT DENSE_RANK() over (partition by TPSQueryID order by InsertDate desc) as row_num, * 
        from <Customer>.agd.tblQAResults  ) AS Queries WHERE row_num = 2) qryP ON
						Q.TPSQueryId = qryP.TPSQueryId
				AND		Q.TPSScenarioTypeId = qryP.TPSScenarioTypeId
				LEFT JOIN (Select TPSQueryID, TPSScenarioTypeId, avg_results = AVG(RESULT), STD_DEV = STDEV(RESULT), LOWER_BOUND = AVG(RESULT) - STDEV(RESULT), UPPER_BOUND = AVG(RESULT) + STDEV(RESULT) FROM ( SELECT DENSE_RANK() over (partition by TPSQueryID order by InsertDate desc) as row_num, * 
        from <Customer>.agd.tblQAResults  ) AS Queries WHERE row_num <= 10 AND TRY_CAST(InsertDate AS date) > TRY_CAST(DATEADD(month, -3, GETDATE()) AS date) GROUP BY TPSQueryID, TPSScenarioTypeId) qryAVG ON
						Q.TPSQueryId = qryAVG.TPSQueryId
				AND		Q.TPSScenarioTypeId = qryAVG.TPSScenarioTypeId
		WHERE  NOT ( QueryDescription = 'AgileD run fails' --AND qar.Result = CAST(0 AS VARCHAR(50))
		)
		AND qryC.TPSQueryID in 	(	SELECT distinct TPSQueryID from <Customer>.agd.tblQAResults where TPSQueryID in (SELECT TPSQueryID from <Customer>.agd.tblQAQuery where Active = 1	)	)
		and TRY_CAST(qryC.InsertDate AS date) > TRY_CAST(DATEADD(month, -3, GETDATE()) AS date)

		

 UNION ALL 


    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE 'ClientName') AS Customer,'<Customer>_AGG' AS 'Database', 	
	 QueryID = q.TPSQueryID
				, TPSRunID	= qryC.TPSRunID
				, QueryType = ISNULL(q.QueryType, '')
				, QueryName = ISNULL(q.QueryDescription, '')				
				, AlertType = CASE 
									WHEN q.AlertType = 'WARN' AND q.FailThreshold IS NOT NULL THEN 'Warn/Fail' 
									WHEN q.AlertType = 'WARN' AND q.FailThreshold is NULL THEN 'Warn'
									WHEN q.AlertType = 'FAIL' THEN 'Fail'
									ELSE ''
								END 
				, WarnThreshold = CASE 
										WHEN q.AlertType = 'WARN' THEN CAST(q.PercentOff AS NVARCHAR(10))
										ELSE ''
									END
				, FailThreshold = CASE 
										WHEN q.AlertType = 'Warn' AND q.FailThreshold IS NOT NULL THEN CAST(FailThreshold AS NVARCHAR(10))
										WHEN q.AlertType = 'Fail' THEN CAST(q.PercentOff AS NVARCHAR(10))
										ELSE ''
									END
				, ExpectedResult =  ISNULL(CAST(q.ExpectedResult AS NVARCHAR(50)), '')
				, CurrentDataDate = qryC.Datadate				
				, CurrentResult	=  CASE 
										WHEN QueryResultType = 'DATE' 
											THEN CAST(CAST(CAST(LEFT(qryC.Result, 8) AS VARCHAR(50)) AS DATE) AS VARCHAR(50)) 
											ELSE CAST(qryC.Result AS VARCHAR(50)) 
									END										
				, PriorResult	=  CASE 
										WHEN QueryResultType = 'DATE' 
										THEN 
											CASE 
												WHEN qryP.Result IS NULL THEN '' 
												ELSE CAST(CAST(CAST(LEFT(qryP.Result, 8) AS VARCHAR(50)) AS DATE) AS VARCHAR(50)) END 										
										ELSE CAST(ISNULL(qryP.Result,0) AS VARCHAR(50)) END	
				, PriorDataDate = CAST ( CASE	WHEN qryP.Datadate IS NULL THEN 'N/a' ELSE CAST(convert(varchar, qryP.Datadate, 111) AS varchar) END AS VARCHAR(50)) 			
				, PercentChange	= CAST(	CASE	WHEN (qryP.Result IS NULL OR qryP.Result = 0) AND (qryC.Result IS NULL OR qryC.Result = 0) THEN 0
														WHEN (qryP.Result IS NULL OR qryP.Result = 0) AND qryC.Result <> 0 THEN 100 	
														ELSE (
															CASE WHEN q.QueryResultType = 'DATE' 
																THEN ABS(DATEDIFF(dd, CAST(LEFT(qryP.Result, 8) AS VARCHAR(50)), CAST(LEFT(qryC.Result, 8) AS VARCHAR(50)))) 
																ELSE ABS(100*((qryC.Result - qryP.Result) / qryP.Result)) 
																END)
												END AS DECIMAL(19,4))
				, qryAVG.*
				, qryC.Query
				, Failure	= ISNULL(qryC.IsFailure, 0)
				, Warning = ISNULL(qryC.IsWarning, 0)	
				, qryC.InsertDate															
		FROM	<Customer>_AGG.agd.tblQAQuery q
				INNER JOIN (SELECT * FROM ( SELECT DENSE_RANK() over (partition by TPSQueryID order by InsertDate desc) as row_num, * 
        from <Customer>_AGG.agd.tblQAResults  ) AS Queries WHERE row_num = 1) qryC ON
						Q.TPSQueryId = qryC.TPSQueryId
				AND		Q.TPSScenarioTypeId = qryC.TPSScenarioTypeId
				LEFT JOIN (SELECT * FROM ( SELECT DENSE_RANK() over (partition by TPSQueryID order by InsertDate desc) as row_num, * 
        from <Customer>_AGG.agd.tblQAResults  ) AS Queries WHERE row_num = 2) qryP ON
						Q.TPSQueryId = qryP.TPSQueryId
				AND		Q.TPSScenarioTypeId = qryP.TPSScenarioTypeId
				LEFT JOIN (Select TPSQueryID, TPSScenarioTypeId, avg_results = AVG(RESULT), STD_DEV = STDEV(RESULT), LOWER_BOUND = AVG(RESULT) - STDEV(RESULT), UPPER_BOUND = AVG(RESULT) + STDEV(RESULT) FROM ( SELECT DENSE_RANK() over (partition by TPSQueryID order by InsertDate desc) as row_num, * 
        from <Customer>_AGG.agd.tblQAResults  ) AS Queries WHERE row_num <= 10 AND TRY_CAST(InsertDate AS date) > TRY_CAST(DATEADD(month, -3, GETDATE()) AS date) GROUP BY TPSQueryID, TPSScenarioTypeId) qryAVG ON
						Q.TPSQueryId = qryAVG.TPSQueryId
				AND		Q.TPSScenarioTypeId = qryAVG.TPSScenarioTypeId
		WHERE  NOT ( QueryDescription = 'AgileD run fails' --AND qar.Result = CAST(0 AS VARCHAR(50))
		)
		AND qryC.TPSQueryID in 	(	SELECT distinct TPSQueryID from <Customer>_AGG.agd.tblQAResults where TPSQueryID in (SELECT TPSQueryID from <Customer>_AGG.agd.tblQAQuery where Active = 1	)	)
		and TRY_CAST(qryC.InsertDate AS date) > TRY_CAST(DATEADD(month, -3, GETDATE()) AS date)

		

	
GO


