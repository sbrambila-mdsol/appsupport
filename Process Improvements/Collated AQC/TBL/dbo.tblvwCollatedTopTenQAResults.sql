--replace <schema> with Customer schema

USE StrataLogs
GO
CREATE TABLE [<schema>].[vwCollatedTopTenQAResults](
	[Customer] [varchar](max) NULL,
	[Database] [varchar](22) NOT NULL,
	[row_num] [bigint] NULL,
	[TPSRunId] [int] NOT NULL,
	[QueryID] [int] NOT NULL,
	[TPSScenarioTypeId] [int] NOT NULL,
	[Result] [decimal](19, 4) NOT NULL,
	[DataDate] [date] NULL,
	[Query] [varchar](max) NULL,
	[InsertDate] [datetime] NULL,
	[ExpectedResult] [int] NULL,
	[Failure] [bit] NOT NULL,
	[Warning] [bit] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO