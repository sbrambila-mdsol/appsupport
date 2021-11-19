USE [ApplicationServices]
GO

/****** Object:  Table [dbo].[tblCrushSFTPPasswordExpiration]    Script Date: 6/24/2020 1:41:28 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblCrushSFTPPasswordExpiration](
	[ProjectID] [int] IDENTITY(1,1) NOT NULL,
	[ProjectName] [varchar](200) NULL,
	[PROServerName] [varchar](200) NULL,
	[CrushSFTPURL] [varchar](200) NULL,
	[LastPasswordChangedDate] [varchar](200) NULL
) ON [PRIMARY]
GO


