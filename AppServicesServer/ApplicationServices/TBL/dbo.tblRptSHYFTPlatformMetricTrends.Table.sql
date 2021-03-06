USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblRptSHYFTPlatformMetricTrends]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRptSHYFTPlatformMetricTrends](
	[WeekEnding] [date] NULL,
	[ClientName] [nchar](100) NULL,
	[SettingName] [varchar](24) NOT NULL,
	[SettingValue] [numeric](20, 2) NULL,
	[FilterKey] [nvarchar](137) NULL
) ON [PRIMARY]
GO
