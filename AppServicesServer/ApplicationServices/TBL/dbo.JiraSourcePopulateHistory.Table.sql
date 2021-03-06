USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[JiraSourcePopulateHistory]    Script Date: 4/14/2020 11:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[JiraSourcePopulateHistory](
	[Key] [nvarchar](max) NULL,
	[project] [nvarchar](max) NULL,
	[Created] [date] NULL,
	[ShyftIssue] [int] NULL,
	[CustomerIssue] [int] NULL,
	[DateProviderShyftIssue] [int] NULL,
	[WinnerSrc] [varchar](12) NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
