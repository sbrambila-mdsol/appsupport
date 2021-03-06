USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tes_QA]    Script Date: 4/14/2020 11:24:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tes_QA](
	[Customer] [nvarchar](50) NOT NULL,
	[Database] [nvarchar](50) NOT NULL,
	[QueryID] [int] NOT NULL,
	[QueryType] [nvarchar](50) NOT NULL,
	[QueryName] [nvarchar](200) NULL,
	[AlertType] [nvarchar](50) NOT NULL,
	[WarnThreshold] [int] NULL,
	[FailThreshold] [nvarchar](50) NULL,
	[ExpectedResult] [int] NULL,
	[CurrentDataDate] [datetime2](7) NOT NULL,
	[CurrentResult] [float] NOT NULL,
	[PriorResult] [float] NOT NULL,
	[PriorDataDate] [datetime2](7) NOT NULL,
	[PercentChange] [float] NOT NULL,
	[TPSQueryID] [int] NOT NULL,
	[TPSScenarioTypeId] [int] NOT NULL,
	[avg_results] [float] NOT NULL,
	[STD_DEV] [float] NOT NULL,
	[LOWER_BOUND] [float] NOT NULL,
	[UPPER_BOUND] [float] NOT NULL,
	[Query] [nvarchar](50) NOT NULL,
	[Failure] [bit] NOT NULL,
	[Warning] [bit] NOT NULL,
	[InsertDate] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
