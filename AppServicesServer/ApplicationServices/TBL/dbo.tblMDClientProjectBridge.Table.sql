USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblMDClientProjectBridge]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblMDClientProjectBridge](
	[Client] [nvarchar](60) NULL,
	[JiraProjectName] [varchar](25) NULL
) ON [PRIMARY]
GO
