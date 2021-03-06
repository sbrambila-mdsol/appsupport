USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspLoadSHYFTPlatformSummary]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================= 
-- SELECT * FROM tblRptSHYFTPlatformSummary
-- =============================================
CREATE PROCEDURE [dbo].[uspLoadSHYFTPlatformSummary]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @intDateDelta int 
	SET @intDateDelta = -1
	DROP TABLE IF EXISTS tblRptSHYFTPlatformSummary

	;WITH LatestProcessingStatus AS (
		SELECT customerStats.*
		FROM (SELECT ClientName, DataSource, LatestPullTime = MAX(InsertTime)
			FROM [SUNNY_IM].[dbo].[tbldfProcessingDataCapture] 
			GROUP BY ClientName,DataSource 
			) latestStats
		LEFT JOIN [SUNNY_IM].[dbo].[tbldfProcessingDataCapture]  customerStats
			ON latestStats.ClientName = customerStats.ClientName
			AND latestStats.DataSource = customerStats.DataSource
			AND latestStats.LatestPullTime = customerStats.InsertTime	
	), LatestProductionStatus AS (
		SELECT customerStats.*
		FROM (SELECT ClientName, DataSource, LatestPullTime = MAX(InsertTime)
			FROM [SUNNY_IM].[dbo].[tbldfProductionDataCapture] 
			GROUP BY ClientName,DataSource 
			) latestStats
		LEFT JOIN [SUNNY_IM].[dbo].[tbldfProductionDataCapture]  customerStats
			ON latestStats.ClientName = customerStats.ClientName
			AND latestStats.DataSource = customerStats.DataSource
			AND latestStats.LatestPullTime = customerStats.InsertTime	
	), priorLatestProcessingStatus AS (
		SELECT customerStats.*
		FROM (SELECT ClientName, DataSource, LatestPullTime = MAX(InsertTime)
			FROM [SUNNY_IM].[dbo].[tbldfProcessingDataCapture] 
			WHERE YEAR(InsertTime) = YEAR( DATEADD(ww, -1, GETDATE()) )
				AND DATEPART(ww,InsertTime) = DATEPART( ww, DATEADD(WW, -1, GETDATE()) )
			GROUP BY ClientName,DataSource 
			) latestStats
		LEFT JOIN [SUNNY_IM].[dbo].[tbldfProcessingDataCapture]  customerStats
			ON latestStats.ClientName = customerStats.ClientName
			AND latestStats.DataSource = customerStats.DataSource
			AND latestStats.LatestPullTime = customerStats.InsertTime	
	), priorProductionStatus AS (
		SELECT customerStats.*
		FROM (SELECT ClientName, DataSource, LatestPullTime = MAX(InsertTime)
			FROM [SUNNY_IM].[dbo].[tbldfProductionDataCapture] 
			WHERE YEAR(InsertTime) = YEAR( DATEADD(ww, -1, GETDATE()) )
				AND DATEPART(ww,InsertTime) = DATEPART( ww, DATEADD(WW, -1, GETDATE()) )
			GROUP BY ClientName,DataSource 
			) latestStats
		LEFT JOIN [SUNNY_IM].[dbo].[tbldfProductionDataCapture]  customerStats
			ON latestStats.ClientName = customerStats.ClientName
			AND latestStats.DataSource = customerStats.DataSource
			AND latestStats.LatestPullTime = customerStats.InsertTime	
	)

	SELECT 
		CustomerCount = 1 
		, LatestProcessingStatus.*
		, LatestProdStatusAgg.LumenV2_UserCount
		, LatestProdStatusAgg.CC_UserCount
		, LatestProdStatusAgg.CC_IM_RowCount
		, LatestProdStatusAgg.CC_IM_UsedSpaceGB
		, LumenVersion = CASE WHEN LatestProcessingStatus.LumenV3_UserCount IS NOT NULL THEN 'v3' WHEN LatestProdStatusAgg.LumenV2_UserCount IS NOT NULL THEN 'v2' ELSE NULL END
		, Lumen_UserCount = ISNULL(LatestProcessingStatus.LumenV3_UserCount, LatestProdStatusAgg.LumenV2_UserCount)
		, priorTotalActiveDataFeeds = priorLatestProcessingStatus.TotalActiveDataFeeds
		, priorQC_Active = priorLatestProcessingStatus.QC_Active
		, priorTotalActiveVeevaObjects = priorLatestProcessingStatus.TotalActiveVeevaObjects
		, priorVeeva_Account = priorLatestProcessingStatus.Veeva_Account
		, priorIM_RowCount = priorLatestProcessingStatus.IM_RowCount
		, priorIM_UsedSpaceGB = priorLatestProcessingStatus.IM_UsedSpaceGB
		, priorADHOC_RowCount = priorLatestProcessingStatus.ADHOC_RowCount
		, priorADHOC_UsedSpaceGB = priorLatestProcessingStatus.ADHOC_UsedSpaceGB
		, priorHCP_Mastered = priorLatestProcessingStatus.HCP_Mastered
		, priorHCO_Mastered = priorLatestProcessingStatus.HCO_Mastered
		, priorPatient_Mastered = priorLatestProcessingStatus.Patient_Mastered
		
	INTO tblRptSHYFTPlatformSummary
	FROM ( SELECT DISTINCT ClientName FROM [SUNNY_IM].[dbo].[tbldfProcessingDataCapture]) ClientMaster
	LEFT JOIN LatestProcessingStatus ON ClientMaster.ClientName = LatestProcessingStatus.ClientName
	LEFT JOIN priorLatestProcessingStatus ON ClientMaster.ClientName = priorLatestProcessingStatus.ClientName
	LEFT JOIN (SELECT ClientName
					, Max(LumenV2_UserCount) AS LumenV2_UserCount
					, Max(CC_UserCount) AS CC_UserCount
					, Max(CC_IM_RowCount) AS CC_IM_RowCount
					, Max(CC_IM_UsedSpaceGB) AS CC_IM_UsedSpaceGB
					FROM LatestProductionStatus GROUP BY ClientName) LatestProdStatusAgg 
			ON ClientMaster.ClientName = LatestProdStatusAgg.ClientName
		     
END
GO
