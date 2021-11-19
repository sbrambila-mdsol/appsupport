--replace <schema> with customer schema

USE StrataLogs
GO
CREATE TABLE [<Schema>].[vwCollatedErroredAQC](
	[Customer] [varchar](max) NULL,
	[Database] [varchar](22) NOT NULL,
	[TPSScenarioTypeId] [int] NULL,
	[FailedAQCQueryIDs] [varchar](max) NULL,
	[InsertDate] [datetime] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO