USE [ApplicationServices_IM]
GO

/****** Object:  Table [dbo].[AllProdRunTickets_Daily]    Script Date: 4/13/2020 12:03:12 PM ******/
DROP TABLE [dbo].[AllProdRunTickets_Daily]
GO

/****** Object:  Table [dbo].[AllProdRunTickets_Daily]    Script Date: 4/13/2020 12:03:12 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AllProdRunTickets_Daily](
	[Key] [nvarchar](255) NULL,
	[Project] [nvarchar](255) NULL,
	[Summary] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[Created] [nvarchar](255) NULL,
	[Updated] [nvarchar](255) NULL,
	[ResolutionDate] [nvarchar](255) NULL,
	[Epic] [nvarchar](255) NULL,
	[IssueFree] [nvarchar](255) NULL,
	[OnTime] [nvarchar](255) NULL,
	[Source] [nvarchar](255) NULL,
	[HandledBy] [nvarchar](255) NULL,
	[Assignee] [nvarchar](255) NULL
) ON [PRIMARY]
GO


