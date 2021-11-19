USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[Scenarios]    Script Date: 4/14/2020 11:24:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Scenarios](
	[TPSScenarioTypeId] [int] NOT NULL,
	[ScenarioType] [nvarchar](100) NOT NULL,
	[ScenarioTypeDescription] [nvarchar](150) NOT NULL,
	[InsertDate] [datetime2](7) NOT NULL
) ON [PRIMARY]
GO
