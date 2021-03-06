USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblAppSrv_JIRAALLInProgressDeploy]    Script Date: 4/14/2020 11:24:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAppSrv_JIRAALLInProgressDeploy](
	[Project] [nvarchar](255) NULL,
	[Key] [nvarchar](255) NULL,
	[Summary] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[Created] [nvarchar](255) NULL,
	[Updated] [nvarchar](255) NULL,
	[ResolutionDate] [nvarchar](255) NULL,
	[Epic] [nvarchar](255) NULL,
	[IssueFree] [nvarchar](255) NULL,
	[DeployEnv] [nvarchar](255) NULL,
	[Planned] [nvarchar](255) NULL,
	[Reporter] [nvarchar](255) NULL,
	[Assignee] [nvarchar](255) NULL
) ON [PRIMARY]
GO
