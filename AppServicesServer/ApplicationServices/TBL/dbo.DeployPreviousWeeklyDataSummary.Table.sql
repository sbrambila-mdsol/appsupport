USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[DeployPreviousWeeklyDataSummary]    Script Date: 4/14/2020 11:24:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DeployPreviousWeeklyDataSummary](
	[Project] [nvarchar](max) NULL,
	[Total] [int] NULL,
	[UnPlanned] [int] NULL,
	[Planned] [int] NULL,
	[PRD] [int] NULL,
	[UAT] [int] NULL,
	[Late] [int] NULL,
	[Issues] [int] NULL,
	[StartDt] [date] NULL,
	[EndDt] [date] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
