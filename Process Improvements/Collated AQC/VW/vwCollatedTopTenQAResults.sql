USE [TPS_DBA]
GO

/****** Object:  View [dbo].[vwCollatedTopTenQAResults]    Script Date: 1/14/2020 1:02:44 PM ******/
DROP VIEW IF EXISTS [dbo].[vwCollatedTopTenQAResults]
GO

/****** Object:  View [dbo].[vwCollatedTopTenQAResults]    Script Date: 1/14/2020 1:02:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


	CREATE VIEW [dbo].[vwCollatedTopTenQAResults]

	AS

	
    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE 'ClientName') AS Customer, '<Customer>' AS 'Database', 	
	row_num, qryAVG.TPSRunId, QueryID = q.TPSQueryID, qryAVG.TPSScenarioTypeId, qryAVG.Result, qryAVG.DataDate, qryAVG.Query, qryAVG.InsertDate, qryAVG.ExpectedResult
				, Failure	= ISNULL(qryAVG.IsFailure, 0)
				, Warning = ISNULL(qryAVG.IsWarning, 0)									
		FROM	<Customer>.agd.tblQAQuery q
				INNER JOIN (Select * FROM ( SELECT DENSE_RANK() over (partition by TPSQueryID order by InsertDate desc) as row_num, * 
        from <Customer>.agd.tblQAResults  ) AS Queries WHERE row_num <= 10 ) qryAVG ON
						Q.TPSQueryId = qryAVG.TPSQueryId
				AND		Q.TPSScenarioTypeId = qryAVG.TPSScenarioTypeId
		WHERE  NOT ( QueryDescription = 'AgileD run fails' 
		)
		AND qryAVG.TPSQueryID in 
		(	SELECT distinct TPSQueryID from <Customer>.agd.tblQAResults where TPSQueryID in (SELECT TPSQueryID from <Customer>.agd.tblQAQuery where Active = 1	)	)
		and TRY_CAST(qryAVG.InsertDate AS date) > TRY_CAST(DATEADD(month, -3, GETDATE()) AS date)

		

 UNION ALL 


    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE 'ClientName') AS Customer, '<Customer>_AGG' AS 'Database', 	
	row_num, qryAVG.TPSRunId, QueryID = q.TPSQueryID, qryAVG.TPSScenarioTypeId, qryAVG.Result, qryAVG.DataDate, qryAVG.Query, qryAVG.InsertDate, qryAVG.ExpectedResult
				, Failure	= ISNULL(qryAVG.IsFailure, 0)
				, Warning = ISNULL(qryAVG.IsWarning, 0)									
		FROM	<Customer>_AGG.agd.tblQAQuery q
				INNER JOIN (Select * FROM ( SELECT DENSE_RANK() over (partition by TPSQueryID order by InsertDate desc) as row_num, * 
        from <Customer>_AGG.agd.tblQAResults  ) AS Queries WHERE row_num <= 10 ) qryAVG ON
						Q.TPSQueryId = qryAVG.TPSQueryId
				AND		Q.TPSScenarioTypeId = qryAVG.TPSScenarioTypeId
		WHERE  NOT ( QueryDescription = 'AgileD run fails' 
		)
		AND qryAVG.TPSQueryID in 
		(	SELECT distinct TPSQueryID from <Customer>_AGG.agd.tblQAResults where TPSQueryID in (SELECT TPSQueryID from <Customer>_AGG.agd.tblQAQuery where Active = 1	)	)
		and TRY_CAST(qryAVG.InsertDate AS date) > TRY_CAST(DATEADD(month, -3, GETDATE()) AS date)

		

	
GO


