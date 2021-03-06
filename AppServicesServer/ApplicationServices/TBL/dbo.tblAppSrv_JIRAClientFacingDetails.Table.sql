USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblAppSrv_JIRAClientFacingDetails]    Script Date: 4/14/2020 11:24:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAppSrv_JIRAClientFacingDetails](
	[Project] [nvarchar](255) NULL,
	[Key] [nvarchar](max) NULL,
	[TypeofIssue] [nvarchar](255) NULL,
	[Summary] [nvarchar](max) NULL,
	[Status] [nvarchar](max) NULL,
	[Client_Facing] [nvarchar](max) NULL,
	[Created] [nvarchar](max) NULL,
	[Updated] [nvarchar](max) NULL,
	[ResolutionDate] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
