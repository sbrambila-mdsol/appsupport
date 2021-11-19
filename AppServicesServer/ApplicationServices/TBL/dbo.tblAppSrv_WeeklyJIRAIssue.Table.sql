USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblAppSrv_WeeklyJIRAIssue]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAppSrv_WeeklyJIRAIssue](
	[Project] [nvarchar](255) NULL,
	[WeekEnding] [date] NULL,
	[IssuesCount] [int] NULL
) ON [PRIMARY]
GO
