USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[par_QA_scenario]    Script Date: 4/14/2020 11:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[par_QA_scenario](
	[Customer] [nvarchar](50) NOT NULL,
	[Database] [nvarchar](50) NOT NULL,
	[TPSScenarioTypeId] [int] NOT NULL,
	[ScenarioType] [nvarchar](100) NOT NULL,
	[ScenarioTypeDescription] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
