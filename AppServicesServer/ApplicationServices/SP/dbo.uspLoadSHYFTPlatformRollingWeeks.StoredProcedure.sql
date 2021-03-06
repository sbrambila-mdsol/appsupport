USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspLoadSHYFTPlatformRollingWeeks]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ============================================= 
-- SELECT * FROM tblRptSHYFTPlatformRollingWeeks
-- SELECT * FROM tblRptSHYFTPlatformMetricTrends
-- =============================================
CREATE PROCEDURE [dbo].[uspLoadSHYFTPlatformRollingWeeks]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @dtDateLimit DATETIME 
	SET @dtDateLimit = DATEADD(mm,-3,GETDATE())
	DROP TABLE IF EXISTS  tblRptSHYFTPlatformRollingWeeks

	
	;WITH LatestProcessingStatus AS (
		SELECT weekYear, customerStats.*
		FROM (SELECT ClientName, DataSource, LatestPullTime = MAX(InsertTime), weekYear = DATEADD(DAY, 7 - DATEPART(WEEKDAY, InsertTime), CAST(InsertTime AS DATE)) 
			FROM [SUNNY_IM].[dbo].[tbldfProcessingDataCapture] 
			GROUP BY ClientName,DataSource, DATEADD(DAY, 7 - DATEPART(WEEKDAY, InsertTime), CAST(InsertTime AS DATE)) 
			) latestStats
		LEFT JOIN [SUNNY_IM].[dbo].[tbldfProcessingDataCapture]  customerStats
			ON latestStats.ClientName = customerStats.ClientName
			AND latestStats.DataSource = customerStats.DataSource
			AND latestStats.LatestPullTime = customerStats.InsertTime	
	), LatestProductionStatus AS (
		SELECT weekYear, customerStats.*
		FROM (SELECT ClientName, DataSource, LatestPullTime = MAX(InsertTime), weekYear = DATEADD(DAY, 7 - DATEPART(WEEKDAY, InsertTime), CAST(InsertTime AS DATE)) 
			FROM [SUNNY_IM].[dbo].[tbldfProductionDataCapture] 
			GROUP BY ClientName,DataSource, DATEADD(DAY, 7 - DATEPART(WEEKDAY, InsertTime), CAST(InsertTime AS DATE)) 
			) latestStats
		LEFT JOIN [SUNNY_IM].[dbo].[tbldfProductionDataCapture]  customerStats
			ON latestStats.ClientName = customerStats.ClientName
			AND latestStats.DataSource = customerStats.DataSource
			AND latestStats.LatestPullTime = customerStats.InsertTime	
	)

	SELECT 
		  LatestProcessingStatus.*
		, LatestProdStatusAgg.LumenV2_UserCount
		, LatestProdStatusAgg.CC_UserCount
		, LatestProdStatusAgg.CC_IM_RowCount
		, LatestProdStatusAgg.CC_IM_UsedSpaceGB
		, LumenVersion = CASE WHEN LumenV3_UserCount IS NOT NULL THEN 'v3' WHEN LumenV2_UserCount IS NOT NULL THEN 'v2' ELSE NULL END
		, Lumen_UserCount = ISNULL(LumenV3_UserCount, LumenV2_UserCount)
	INTO tblRptSHYFTPlatformRollingWeeks
	FROM ( SELECT DISTINCT  ClientName FROM [SUNNY_IM].[dbo].[tbldfProcessingDataCapture] WHERE InsertTime >= @dtDateLimit) ClientMaster
	LEFT JOIN LatestProcessingStatus ON ClientMaster.ClientName = LatestProcessingStatus.ClientName
	LEFT JOIN (SELECT ClientName, weekYear
					, Max(LumenV2_UserCount) AS LumenV2_UserCount
					, Max(CC_UserCount) AS CC_UserCount
					, Max(CC_IM_RowCount) AS CC_IM_RowCount
					, Max(CC_IM_UsedSpaceGB) AS CC_IM_UsedSpaceGB
					FROM LatestProductionStatus GROUP BY ClientName, weekYear) LatestProdStatusAgg 
			ON ClientMaster.ClientName = LatestProdStatusAgg.ClientName
			AND LatestProcessingStatus.weekYear = LatestProdStatusAgg.weekYear

	-- create trend table
	DROP TABLE IF EXISTS tblRptSHYFTPlatformMetricTrends

	SELECT weekYear As WeekEnding, ClientName, SettingName = 'Lumen User', SettingValue  = CAST(Lumen_UserCount AS NUMERIC(20,2)),  FilterKey = ClientName + ' Please replace the setting name here'  
	INTO tblRptSHYFTPlatformMetricTrends
	FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'Command Center User', CAST(CC_UserCount AS NUMERIC(20,2)) ,'' FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'Raw Data Row Count', CAST(IM_RowCount AS NUMERIC(20,2)) , ''  FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'Raw Data Storage (GB)', CAST(IM_UsedSpaceGB AS NUMERIC(20,2)) , ''  FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'AdHoc Row Count', CAST(ADHOC_RowCount AS NUMERIC(20,2)) , ''  FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'AdHoc Storage (GB)', CAST(ADHOC_UsedSpaceGB AS NUMERIC(20,2)) ,'' FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'File Portal Row Count', CAST(CC_IM_RowCount AS NUMERIC(20,2)) ,'' FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'File Portal Storage (MB)', CAST(CC_IM_UsedSpaceGB AS NUMERIC(20,2)) ,'' FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'HCP Mastered', CAST(HCP_Mastered AS NUMERIC(20,2)) ,'' FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'HCO Mastered', CAST(HCO_Mastered AS NUMERIC(20,2)) ,'' FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'Patient Mastered', CAST(Patient_Mastered AS NUMERIC(20,2)) , ''  FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'Payer Mastered', CAST(Payer_Mastered AS NUMERIC(20,2)) ,'' FROM tblRptSHYFTPlatformRollingWeeks
		UNION SELECT weekYear As WeekEnding, ClientName, SettingName = 'Veeva Account Count', CAST(Veeva_Account AS NUMERIC(20,2)) ,'' FROM tblRptSHYFTPlatformRollingWeeks

	UPDATE tblRptSHYFTPlatformMetricTrends SET FilterKey = RTRIM(ClientName) + '_' + Settingname

END
GO
