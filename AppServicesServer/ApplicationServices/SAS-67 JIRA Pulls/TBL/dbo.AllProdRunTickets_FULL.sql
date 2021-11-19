USE [ApplicationServices_IM]
GO

IF EXISTS (SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME='AllProdRunTickets_FULL') DROP TABLE dbo.AllProdRunTickets_FULL

/****** Object:  Table [dbo].[AllProdRunTickets_FULL]    Script Date: 5/17/2019 3:39:20 PM ******/
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
	[Assignee] [nvarchar](255) NULL
) ON [PRIMARY]
GO


