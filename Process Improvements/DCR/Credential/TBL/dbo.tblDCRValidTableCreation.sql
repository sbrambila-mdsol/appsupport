USE [VERASTEM_IM]
GO

/****** Object:  Table [dbo].[tblstgVeevaCredentialDCRValid]    Script Date: 12/5/2019 2:44:42 PM ******/
if exists (select name from sys.objects where name='tblstgVeevaCredentialDCRValid')
DROP TABLE [dbo].[tblstgVeevaCredentialDCRValid]
GO

/****** Object:  Table [dbo].[tblstgVeevaCredentialDCRValid]    Script Date: 12/5/2019 2:44:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblstgVeevaCredentialDCRValid](
	[Id] [nvarchar](68) NULL,
	[Credential_VOD__C] [nvarchar](max) NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO