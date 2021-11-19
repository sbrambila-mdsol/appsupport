USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblAppSrv_JIRAc7dIssues_RootCause]    Script Date: 4/14/2020 11:24:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAppSrv_JIRAc7dIssues_RootCause](
	[Customer] [nvarchar](255) NULL,
	[ProdIssueRootCause] [nvarchar](max) NULL,
	[IssuesCount] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
