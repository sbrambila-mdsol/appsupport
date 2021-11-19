USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[tbldfOpenAirHours_HISTORY]    Script Date: 4/13/2020 3:15:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbldfOpenAirHours_HISTORY](
	[HistoryID] [bigint] IDENTITY(1,1) NOT NULL,
	[HistoryDataDate] [bigint] NULL,
	[DataFeedID] [int] NULL,
	[YearMth] [nvarchar](10) NULL,
	[Date] [nvarchar](10) NULL,
	[Client] [nvarchar](60) NULL,
	[Project] [nvarchar](70) NULL,
	[Task] [nvarchar](80) NULL,
	[TimeHrMin] [nvarchar](30) NULL,
	[Hours] [nvarchar](10) NULL,
	[Firstname] [nvarchar](20) NULL,
	[Lastname] [nvarchar](20) NULL
) ON [PRIMARY]
GO
