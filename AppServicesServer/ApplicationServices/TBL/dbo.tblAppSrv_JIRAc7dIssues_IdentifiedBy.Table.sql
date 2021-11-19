USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblAppSrv_JIRAc7dIssues_IdentifiedBy]    Script Date: 4/14/2020 11:24:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAppSrv_JIRAc7dIssues_IdentifiedBy](
	[Customer] [nvarchar](255) NULL,
	[Identified_By] [nvarchar](255) NULL,
	[IssuesCount] [int] NULL
) ON [PRIMARY]
GO
