USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblRptSHYFTPlatformClientStatsList]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRptSHYFTPlatformClientStatsList](
	[ClientName] [nchar](100) NULL,
	[SettingName] [varchar](24) NOT NULL,
	[SettingValue] [nvarchar](100) NULL,
	[TrendEnabled] [int] NOT NULL,
	[FilterKey] [nvarchar](142) NULL
) ON [PRIMARY]
GO
