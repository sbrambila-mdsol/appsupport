USE [ApplicationServices_IM]
GO

/****** Object:  Table [dbo].[AllProdRunTickets_FULL]    Script Date: 4/13/2020 11:59:18 AM ******/
DROP TABLE [dbo].[AllProdRunTickets_FULL]
GO

/****** Object:  Table [dbo].[AllProdRunTickets_FULL]    Script Date: 4/13/2020 11:59:18 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AllProdRunTickets_FULL](
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


