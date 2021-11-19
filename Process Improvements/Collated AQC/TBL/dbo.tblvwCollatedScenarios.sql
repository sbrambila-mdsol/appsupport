--replace <schema> with Customer schema

USE StrataLogs
GO
CREATE TABLE [<Schema>].[vwCollatedScenarios](
	[Customer] [varchar](max) NULL,
	[Database] [varchar](22) NOT NULL,
	[TPSScenarioTypeId] [int] NOT NULL,
	[ScenarioType] [varchar](250) NOT NULL,
	[ScenarioTypeDescription] [varchar](250) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO