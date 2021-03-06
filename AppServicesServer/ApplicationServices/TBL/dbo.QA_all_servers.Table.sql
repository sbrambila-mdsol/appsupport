USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[QA_all_servers]    Script Date: 4/14/2020 11:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QA_all_servers](
	[Customer] [nvarchar](500) NOT NULL,
	[Database] [nvarchar](500) NOT NULL,
	[QueryID] [int] NOT NULL,
	[TPSRunID] [int] NULL,
	[QueryType] [nvarchar](500) NOT NULL,
	[QueryName] [nvarchar](2000) NULL,
	[AlertType] [nvarchar](500) NOT NULL,
	[WarnThreshold] [nvarchar](50) NULL,
	[FailThreshold] [nvarchar](50) NULL,
	[ExpectedResult] [nvarchar](500) NULL,
	[CurrentDataDate] [date] NOT NULL,
	[CurrentResult] [nvarchar](500) NOT NULL,
	[PriorResult] [nvarchar](500) NOT NULL,
	[PriorDataDate] [nvarchar](500) NOT NULL,
	[PercentChange] [float] NOT NULL,
	[TPSQueryID] [int] NOT NULL,
	[TPSScenarioTypeId] [int] NOT NULL,
	[avg_results] [float] NULL,
	[STD_DEV] [float] NULL,
	[LOWER_BOUND] [float] NULL,
	[UPPER_BOUND] [float] NULL,
	[Query] [nvarchar](max) NULL,
	[Failure] [int] NULL,
	[Warning] [int] NULL,
	[InsertDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
