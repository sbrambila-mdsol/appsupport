--replace <schema> with Customer schema

USE StrataLogs
GO
CREATE TABLE [<Schema>].[vwCollatedQAResults](
	[Customer] [varchar](max) NULL,
	[Database] [varchar](22) NOT NULL,
	[QueryID] [int] NOT NULL,
	[TPSRunID] [int] NULL,
	[QueryType] [varchar](100) NOT NULL,
	[QueryName] [varchar](300) NOT NULL,
	[AlertType] [varchar](9) NOT NULL,
	[WarnThreshold] [nvarchar](10) NULL,
	[FailThreshold] [nvarchar](10) NULL,
	[ExpectedResult] [nvarchar](50) NOT NULL,
	[CurrentDataDate] [date] NULL,
	[CurrentResult] [varchar](50) NULL,
	[PriorResult] [varchar](50) NULL,
	[PriorDataDate] [varchar](50) NULL,
	[PercentChange] [decimal](19, 4) NULL,
	[TPSQueryID] [int] NULL,
	[TPSScenarioTypeId] [int] NULL,
	[avg_results] [decimal](38, 6) NULL,
	[STD_DEV] [float] NULL,
	[LOWER_BOUND] [float] NULL,
	[UPPER_BOUND] [float] NULL,
	[Query] [varchar](max) NULL,
	[Failure] [bit] NOT NULL,
	[Warning] [bit] NOT NULL,
	[InsertDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO