USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[QA_last10_all_servers]    Script Date: 4/14/2020 11:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QA_last10_all_servers](
	[Customer] [nvarchar](50) NULL,
	[Database] [nvarchar](50) NOT NULL,
	[row_num] [int] NOT NULL,
	[TPSRunId] [int] NOT NULL,
	[QueryID] [int] NOT NULL,
	[TPSScenarioTypeId] [int] NOT NULL,
	[Result] [float] NOT NULL,
	[DataDate] [datetime2](7) NOT NULL,
	[Query] [nvarchar](max) NULL,
	[InsertDate] [datetime2](7) NOT NULL,
	[ExpectedResult] [varchar](500) NULL,
	[Failure] [bit] NULL,
	[Warning] [bit] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
