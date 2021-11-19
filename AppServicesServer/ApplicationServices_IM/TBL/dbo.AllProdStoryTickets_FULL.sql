USE [ApplicationServices_IM]
GO

/****** Object:  Table [dbo].[AllProdStoryTickets_FULL]    Script Date: 4/13/2020 3:05:35 PM ******/
DROP TABLE [dbo].[AllProdStoryTickets_FULL]
GO

/****** Object:  Table [dbo].[AllProdStoryTickets_FULL]    Script Date: 4/13/2020 3:05:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AllProdStoryTickets_FULL](
	[Key] [nvarchar](255) NULL,
	[Project] [nvarchar](255) NULL,
	[Summary] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[Created] [nvarchar](255) NULL,
	[Updated] [nvarchar](255) NULL,
	[Resolutiondate] [nvarchar](255) NULL,
	[Priority] [nvarchar](255) NULL,
	[StoryType] [nvarchar](255) NULL,
	[StoryPts] [nvarchar](255) NULL,
	[IdentifiedBy] [nvarchar](255) NULL,
	[ClientFacing] [nvarchar](255) NULL,
	[Reporter] [nvarchar](255) NULL,
	[Assignee] [nvarchar](255) NULL
) ON [PRIMARY]
GO


