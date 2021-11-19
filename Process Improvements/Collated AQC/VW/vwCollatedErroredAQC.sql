USE [TPS_DBA]
GO

/****** Object:  View [dbo].[vwCollatedErroredAQC]    Script Date: 1/14/2020 1:02:58 PM ******/
DROP VIEW IF EXISTS [dbo].[vwCollatedErroredAQC]
GO

/****** Object:  View [dbo].[vwCollatedErroredAQC]    Script Date: 1/14/2020 1:02:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


	CREATE VIEW [dbo].[vwCollatedErroredAQC]

	AS

	
    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE 'ClientName') AS Customer, '<Customer>' AS 'Database', TPSScenarioTypeId, SUBSTRING(ErrorMessage, 41, LEN(ErrorMessage) - 40) as FailedAQCQueryIDs, InsertDate
	FROM (SELECT * FROM ( SELECT DENSE_RANK() over (partition by TPSScenarioTypeId order by InsertDate desc) as row_num, * 
        from <Customer>.agd.tblMdDataRunLog WHERE ExecProcess like 'AGD.uspQAGenerate%' AND (ErrorMessage IS NULL OR ErrorMessage LIKE 'QA query error encountered in QueryId%')  ) AS Queries WHERE row_num = 1) qryC
	WHERE TRY_CAST(InsertDate AS date) >= TRY_CAST(DATEADD(month, -3, GETDATE()) AS date)
	AND ERRORMESSAGE IS NOT NULL
		

 UNION ALL 


    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE 'ClientName') AS Customer, '<Customer>_CM' AS 'Database', TPSScenarioTypeId, SUBSTRING(ErrorMessage, 41, LEN(ErrorMessage) - 40) as FailedAQCQueryIDs, InsertDate
	FROM (SELECT * FROM ( SELECT DENSE_RANK() over (partition by TPSScenarioTypeId order by InsertDate desc) as row_num, * 
        from <Customer>_CM.agd.tblMdDataRunLog WHERE ExecProcess like 'AGD.uspQAGenerate%' AND (ErrorMessage IS NULL OR ErrorMessage LIKE 'QA query error encountered in QueryId%')  ) AS Queries WHERE row_num = 1) qryC
	WHERE TRY_CAST(InsertDate AS date) >= TRY_CAST(DATEADD(month, -3, GETDATE()) AS date)
	AND ERRORMESSAGE IS NOT NULL
		

 UNION ALL 


    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE 'ClientName') AS Customer, '<Customer>_AGG' AS 'Database', TPSScenarioTypeId, SUBSTRING(ErrorMessage, 41, LEN(ErrorMessage) - 40) as FailedAQCQueryIDs, InsertDate
	FROM (SELECT * FROM ( SELECT DENSE_RANK() over (partition by TPSScenarioTypeId order by InsertDate desc) as row_num, * 
        from <Customer>_AGG.agd.tblMdDataRunLog WHERE ExecProcess like 'AGD.uspQAGenerate%' AND (ErrorMessage IS NULL OR ErrorMessage LIKE 'QA query error encountered in QueryId%')  ) AS Queries WHERE row_num = 1) qryC
	WHERE TRY_CAST(InsertDate AS date) >= TRY_CAST(DATEADD(month, -3, GETDATE()) AS date)
	AND ERRORMESSAGE IS NOT NULL
		

	
GO


