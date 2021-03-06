USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblAppSrv_JIRAOpenIssueDetails]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAppSrv_JIRAOpenIssueDetails](
	[Project] [nvarchar](255) NULL,
	[Key] [nvarchar](255) NULL,
	[Summary] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[Client_Facing] [nvarchar](255) NULL,
	[Identified_By] [nvarchar](255) NULL,
	[Source] [nvarchar](255) NULL,
	[ProdIssueRootCause] [nvarchar](max) NULL,
	[IssuePriority] [nvarchar](255) NULL,
	[Created] [nvarchar](255) NULL,
	[Updated] [nvarchar](255) NULL,
	[Resolution] [nvarchar](max) NULL,
	[ResolutionDate] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
