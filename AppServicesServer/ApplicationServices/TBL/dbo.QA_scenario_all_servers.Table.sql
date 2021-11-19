USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[QA_scenario_all_servers]    Script Date: 4/14/2020 11:24:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QA_scenario_all_servers](
	[Customer] [nvarchar](50) NOT NULL,
	[Database] [nvarchar](50) NOT NULL,
	[TPSScenarioTypeId] [int] NOT NULL,
	[ScenarioType] [nvarchar](4000) NOT NULL,
	[ScenarioTypeDescription] [nvarchar](4000) NOT NULL
) ON [PRIMARY]
GO
