USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[par_QA_last10]    Script Date: 4/14/2020 11:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[par_QA_last10](
	[Customer] [nvarchar](50) NOT NULL,
	[Database] [nvarchar](50) NOT NULL,
	[row_num] [int] NOT NULL,
	[TPSRunId] [int] NOT NULL,
	[QueryID] [int] NOT NULL,
	[TPSScenarioTypeId] [int] NOT NULL,
	[Result] [float] NOT NULL,
	[DataDate] [datetime2](7) NOT NULL,
	[Query] [nvarchar](50) NOT NULL,
	[InsertDate] [datetime2](7) NOT NULL,
	[ExpectedResult] [nvarchar](50) NULL,
	[Failure] [bit] NOT NULL,
	[Warning] [bit] NOT NULL
) ON [PRIMARY]
GO
