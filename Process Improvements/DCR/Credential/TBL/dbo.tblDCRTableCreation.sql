USE [VERASTEM]
GO

/****** Object:  Table [dbo].[tblstgVeevaCredentialDCR]    Script Date: 12/5/2019 2:44:42 PM ******/
if exists (select name from sys.objects where name='tblstgVeevaCredentialDCR')
DROP TABLE [dbo].[tblstgVeevaCredentialDCR]
GO

/****** Object:  Table [dbo].[tblstgVeevaCredentialDCR]    Script Date: 12/5/2019 2:44:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblstgVeevaCredentialDCR](
	[Id] [nvarchar](68) NULL,
	[Credential_VOD__C] [nvarchar](max) NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

