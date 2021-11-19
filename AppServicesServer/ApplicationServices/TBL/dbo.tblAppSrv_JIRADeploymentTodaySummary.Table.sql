USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblAppSrv_JIRADeploymentTodaySummary]    Script Date: 4/14/2020 11:24:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAppSrv_JIRADeploymentTodaySummary](
	[TodayScheduledDeployment] [int] NULL,
	[TodayScheduledDeploymentCompleted] [int] NULL,
	[BadDepolymentTicket7Day] [int] NULL,
	[LateDepolymentTicket7Day] [int] NULL
) ON [PRIMARY]
GO
