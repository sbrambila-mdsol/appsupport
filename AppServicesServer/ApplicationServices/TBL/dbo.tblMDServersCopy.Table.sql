USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblMDServersCopy]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMDServersCopy](
	[Name] [varchar](50) NULL,
	[Conn] [varchar](50) NULL,
	[JiraProjectName] [varchar](50) NULL,
	[SlackChannel] [varchar](50) NULL
) ON [PRIMARY]
GO
