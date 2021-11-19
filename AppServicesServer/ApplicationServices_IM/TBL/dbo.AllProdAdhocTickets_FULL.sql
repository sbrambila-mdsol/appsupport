USE [ApplicationServices_IM]
GO

/****** Object:  Table [dbo].[AllProdAdhocTickets_FULL]    Script Date: 4/13/2020 3:04:03 PM ******/
DROP TABLE [dbo].[AllProdAdhocTickets_FULL]
GO

/****** Object:  Table [dbo].[AllProdAdhocTickets_FULL]    Script Date: 4/13/2020 3:04:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AllProdAdhocTickets_FULL](
	[Key] [nvarchar](max) NULL,
	[Project] [nvarchar](max) NULL,
	[Summary] [nvarchar](max) NULL,
	[Status] [nvarchar](max) NULL,
	[Created] [nvarchar](max) NULL,
	[Updated] [nvarchar](max) NULL,
	[ResolutionDate] [nvarchar](max) NULL,
	[Client_Facing] [nvarchar](max) NULL,
	[IdentifiedBy] [nvarchar](max) NULL,
	[PriorityOrder] [nvarchar](max) NULL,
	[Classification] [nvarchar](max) NULL,
	[IssueType] [nvarchar](max) NULL,
	[Labels] [nvarchar](max) NULL,
	[Priority] [nvarchar](max) NULL,
	[HandledBy] [nvarchar](max) NULL,
	[Reporter] [nvarchar](max) NULL,
	[Assignee] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


