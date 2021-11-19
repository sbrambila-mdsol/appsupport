USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[stgWeeklyWinner]    Script Date: 4/14/2020 11:24:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[stgWeeklyWinner](
	[RowID] [bigint] NULL,
	[Customer] [nvarchar](255) NULL,
	[WeekEnding] [date] NULL,
	[Issues] [int] NULL,
	[IssueRank] [bigint] NULL
) ON [PRIMARY]
GO
