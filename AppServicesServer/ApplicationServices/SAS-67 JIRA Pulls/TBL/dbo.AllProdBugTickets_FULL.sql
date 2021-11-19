USE [ApplicationServices_IM]
GO

IF EXISTS (SELECT object_id FROM sys.tables where name='AllProdBugTickets_FULL') DROP Table [AllProdBugTickets_FULL]

/****** Object:  Table [dbo].[AllProdBugTickets_FULL]    Script Date: 5/17/2019 2:16:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE TABLE [dbo].[AllProdBugTickets_FULL](
	[Key] [nvarchar](max) NULL,
	[Project] [nvarchar](max) NULL,
	[Summary] [nvarchar](max) NULL,
	[Status] [nvarchar](max) NULL,
	[Created] [nvarchar](max) NULL,
	[Updated] [nvarchar](max) NULL,
	[ResolutionDate] [nvarchar](max) NULL,
	[IdentifiedBy] [nvarchar](max) NULL,
	[PriorityOrder] [nvarchar](max) NULL,
	[StoryType] [nvarchar](max) NULL,
	[RootCause] [nvarchar](max) NULL,
	[Classification] [nvarchar](max) NULL,
	[IssueType] [nvarchar](max) NULL,
	[Labels] [nvarchar](max) NULL,
	[Priority] [nvarchar](max) NULL,
	[StoryPts] [nvarchar](max) NULL,
	[Sprint] [nvarchar](max) NULL,
	[Assignee] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


