USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tes_QA_errors]    Script Date: 4/14/2020 11:24:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tes_QA_errors](
	[Customer] [nvarchar](50) NOT NULL,
	[Database] [nvarchar](50) NOT NULL,
	[TPSScenarioTypeId] [int] NOT NULL,
	[FailedAQCQueryIDs] [nvarchar](100) NOT NULL
) ON [PRIMARY]
GO
