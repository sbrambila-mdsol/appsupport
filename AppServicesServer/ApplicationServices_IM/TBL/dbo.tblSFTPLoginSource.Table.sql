USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[tblSFTPLoginSource]    Script Date: 4/13/2020 3:15:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblSFTPLoginSource](
	[User] [varchar](50) NULL,
	[Shyft sFTP Server] [varchar](50) NULL,
	[Shyft sFTP IP Address] [varchar](50) NULL,
	[Client IP Address] [varchar](50) NULL,
	[Connection Method] [varchar](50) NULL,
	[Customer] [varchar](50) NULL
) ON [PRIMARY]
GO
