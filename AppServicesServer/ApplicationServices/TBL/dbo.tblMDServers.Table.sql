USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblMDServers]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMDServers](
	[ServerID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
	[Conn] [varchar](50) NULL,
	[JiraProjectName] [varchar](50) NULL,
	[SlackChannel] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[ServerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
