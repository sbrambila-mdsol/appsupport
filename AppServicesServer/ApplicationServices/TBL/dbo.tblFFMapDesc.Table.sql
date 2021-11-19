USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblFFMapDesc]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFFMapDesc](
	[GrpID] [int] IDENTITY(1,1) NOT NULL,
	[GroupCode] [varchar](25) NULL,
	[GroupDesc] [varchar](255) NULL
) ON [PRIMARY]
GO
