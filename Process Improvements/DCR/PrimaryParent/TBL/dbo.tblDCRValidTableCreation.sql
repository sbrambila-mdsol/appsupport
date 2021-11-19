USE <Customer_IM>--[VERASTEM_IM]
GO

/****** Object:  Table [dbo].[tblstgVeevaDataChangeRequestValid]    Script Date: 10/28/2019 10:05:42 AM ******/
if exists (select name from sys.objects where name='tblstgVeevaDataChangeRequestValid')
DROP TABLE [dbo].[tblstgVeevaDataChangeRequestValid]
GO

/****** Object:  Table [dbo].[tblstgVeevaDataChangeRequestLineValid]    Script Date: 10/28/2019 10:05:42 AM ******/
if exists (select name from sys.objects where name='tblstgVeevaDataChangeRequestLineValid')
DROP TABLE [dbo].[tblstgVeevaDataChangeRequestLineValid]
GO

/****** Object:  Table [dbo].[tblstgVeevaAccountDCRValid]    Script Date: 10/28/2019 10:05:42 AM ******/
if exists (select name from sys.objects where name='tblstgVeevaAccountDCRValid')
DROP TABLE [dbo].[tblstgVeevaAccountDCRValid]
GO

/****** Object:  Table [dbo].[tblstgVeevaAccountDCRValid]    Script Date: 10/28/2019 10:05:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblstgVeevaAccountDCRValid](
	[Id] [nvarchar](68) NULL,
	[PRIMARY_PARENT_VOD__C] [nvarchar](max) NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tblstgVeevaDataChangeRequestLineValid]    Script Date: 10/28/2019 10:05:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblstgVeevaDataChangeRequestLineValid](
	[Id] [nvarchar](68) NULL,
	[resolution_note_vod__c] [varchar](255) NOT NULL,
	[Result_vod__c] [varchar](21) NOT NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tblstgVeevaDataChangeRequestValid]    Script Date: 10/28/2019 10:05:42 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblstgVeevaDataChangeRequestValid](
	[Id] [nvarchar](68) NULL,
	[Notes_vod__c] [varchar](255) NULL,
	[resolution_note_vod__c] [varchar](255) NULL,
	[result_vod__c] [varchar](21) NOT NULL,
	[Status_vod__c] [varchar](9) NOT NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY]
GO


