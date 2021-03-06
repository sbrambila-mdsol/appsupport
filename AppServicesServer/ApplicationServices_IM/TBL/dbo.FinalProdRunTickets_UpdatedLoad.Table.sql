USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[FinalProdRunTickets_UpdatedLoad]    Script Date: 4/13/2020 3:15:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinalProdRunTickets_UpdatedLoad](
	[NewKey] [nvarchar](266) NULL,
	[Project] [nvarchar](255) NULL,
	[summary] [nvarchar](255) NULL,
	[Status] [varchar](4) NOT NULL,
	[created] [date] NULL,
	[updated] [date] NULL,
	[resolutiondate] [date] NULL,
	[epic] [nvarchar](255) NULL,
	[issuefree] [nvarchar](255) NULL,
	[ontime] [nvarchar](255) NULL,
	[Assignee] [nvarchar](255) NULL
) ON [PRIMARY]
GO
