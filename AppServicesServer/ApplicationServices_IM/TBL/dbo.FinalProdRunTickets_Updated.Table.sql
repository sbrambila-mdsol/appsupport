USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[FinalProdRunTickets_Updated]    Script Date: 4/13/2020 3:15:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FinalProdRunTickets_Updated](
	[KEY] [nvarchar](255) NULL,
	[PROJECT] [nvarchar](255) NULL,
	[NEWSUMMARY] [nvarchar](255) NULL,
	[ISSUEFREE] [nvarchar](255) NULL,
	[ONTIME] [nvarchar](255) NULL,
	[DAYOFRUN] [date] NULL,
	[DAYOFWK] [varchar](25) NULL,
	[WeekNo] [int] NULL,
	[epic] [nvarchar](255) NULL
) ON [PRIMARY]
GO
