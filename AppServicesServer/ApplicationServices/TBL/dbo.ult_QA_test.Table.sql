USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[ult_QA_test]    Script Date: 4/14/2020 11:24:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ult_QA_test](
	[Database] [nvarchar](50) NOT NULL,
	[QueryID] [int] NOT NULL,
	[QueryType] [nvarchar](50) NOT NULL,
	[AlertType] [nvarchar](50) NOT NULL,
	[WarnThreshold] [nvarchar](50) NULL,
	[FailThreshold] [nvarchar](50) NULL,
	[ExpectedResult] [int] NULL,
	[CurrentDataDate] [datetime2](7) NOT NULL,
	[CurrentResult] [float] NOT NULL,
	[PriorResult] [float] NOT NULL,
	[PriorDataDate] [datetime2](7) NOT NULL,
	[PercentChange] [float] NOT NULL,
	[TPSScenarioTypeId] [int] NOT NULL,
	[avg_results] [float] NOT NULL,
	[STD_DEV] [float] NOT NULL,
	[LOWER_BOUND] [float] NOT NULL,
	[UPPER_BOUND] [float] NOT NULL,
	[Failure] [bit] NOT NULL,
	[Warning] [bit] NOT NULL,
	[CurrentResultInsertDate] [datetime2](7) NOT NULL,
	[CurrentResultTPSRunId] [int] NOT NULL
) ON [PRIMARY]
GO
