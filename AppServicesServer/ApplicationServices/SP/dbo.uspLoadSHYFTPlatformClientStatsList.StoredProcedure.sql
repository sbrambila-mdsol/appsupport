USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspLoadSHYFTPlatformClientStatsList]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ============================================= 
-- SELECT * FROM tblRptSHYFTPlatformClientStatsList
-- =============================================
CREATE PROCEDURE [dbo].[uspLoadSHYFTPlatformClientStatsList]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
	DROP TABLE IF EXISTS tblRptSHYFTPlatformClientStatsList

	SELECT ClientName, SettingName = 'StrataVersion', SettingValue = StrataVersion ,TrendEnabled = 0, FilterKey = ClientName + 'Setting Name will go in here and replacing'
	INTO tblRptSHYFTPlatformClientStatsList 
	FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'DataDate', DataDate  ,TrendEnabled = 0 ,'' FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'CurrentSprint', CurrentSprint,TrendEnabled = 0  ,'' FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'MedProAPI_Enabled', MedProAPI_Enabled,TrendEnabled = 0 ,''  FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'SF_Configured', SF_Configured ,TrendEnabled = 0,''  FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'VeevaNetwork_Configured', VeevaNetwork_Configured ,TrendEnabled = 0,''  FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'LumenVersion', LumenVersion ,TrendEnabled = 0 ,'' FROM tblRptSHYFTPlatformSummary
		   
		UNION SELECT ClientName, SettingName = 'Lumen User', CAST(Lumen_UserCount AS nvarchar(100)),TrendEnabled = 1,''  FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'Command Center User', CAST(CC_UserCount AS nvarchar(100)) ,TrendEnabled = 1 ,'' FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'Raw Data Row Count', CAST(IM_RowCount AS nvarchar(100)) ,TrendEnabled = 1,''  FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'Raw Data Storage (GB)', CAST(IM_UsedSpaceGB AS nvarchar(100)) ,TrendEnabled = 1,''  FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'AdHoc Row Count', CAST(ADHOC_RowCount AS nvarchar(100)) ,TrendEnabled = 1,''  FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'AdHoc Storage (GB)', CAST(ADHOC_UsedSpaceGB AS nvarchar(100)) ,TrendEnabled = 1 ,'' FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'File Portal Row Count', CAST(CC_IM_RowCount AS nvarchar(100)) ,TrendEnabled = 1 ,'' FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'File Portal Storage (MB)', CAST(CC_IM_UsedSpaceGB AS nvarchar(100)) ,TrendEnabled = 1 ,'' FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'HCP Mastered', CAST(HCP_Mastered AS nvarchar(100)) ,TrendEnabled = 1 ,'' FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'HCO Mastered', CAST(HCO_Mastered AS nvarchar(100)) ,TrendEnabled = 1 ,'' FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'Patient Mastered', CAST(Patient_Mastered AS nvarchar(100)) ,TrendEnabled = 1,''  FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'Payer Mastered', CAST(Payer_Mastered AS nvarchar(100)) ,TrendEnabled = 1 ,'' FROM tblRptSHYFTPlatformSummary
		UNION SELECT ClientName, SettingName = 'Veeva Account Count', CAST(Veeva_Account AS nvarchar(100)) ,TrendEnabled = 1 ,'' FROM tblRptSHYFTPlatformSummary
		   
		   
	-- update labels
	UPDATE tblRptSHYFTPlatformClientStatsList SET   SettingName = REPLACE(SettingName, '_Enabled', '')
	UPDATE tblRptSHYFTPlatformClientStatsList SET   SettingName = REPLACE(SettingName, '_Configured', '')
	UPDATE tblRptSHYFTPlatformClientStatsList SET   FilterKey = RTRIM(ClientName) + '_' + SettingName
END
GO
