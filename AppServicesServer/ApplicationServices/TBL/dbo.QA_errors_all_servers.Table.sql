USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[QA_errors_all_servers]    Script Date: 4/14/2020 11:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QA_errors_all_servers](
	[Customer] [nvarchar](500) NOT NULL,
	[Database] [nvarchar](500) NOT NULL,
	[TPSScenarioTypeId] [int] NOT NULL,
	[FailedAQCQueryIDs] [nvarchar](1000) NULL,
	[InsertDate] [datetime] NOT NULL
) ON [PRIMARY]
GO
