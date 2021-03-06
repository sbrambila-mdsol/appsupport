USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[FixAlnyHistoryRecs]    Script Date: 4/13/2020 3:15:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FixAlnyHistoryRecs](
	[AEKey] [nvarchar](255) NULL,
	[NewKey] [nvarchar](255) NULL,
	[Project] [nvarchar](255) NULL,
	[summary] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[created] [datetime] NULL,
	[updated] [datetime] NULL,
	[resolutiondate] [datetime] NULL,
	[epic] [nvarchar](255) NULL,
	[issuefree] [nvarchar](255) NULL,
	[ontime] [nvarchar](255) NULL,
	[Assignee] [nvarchar](255) NULL
) ON [PRIMARY]
GO
