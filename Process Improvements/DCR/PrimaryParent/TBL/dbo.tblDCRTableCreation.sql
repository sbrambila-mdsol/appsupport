USE <Customer>--[VERASTEM] --replace with Processing db name
GO

/****** Object:  Table [dbo].[tblstgVeevaDataChangeRequestLine]    Script Date: 10/11/2019 4:32:13 PM ******/
if exists (select name from sys.objects where name='tblstgVeevaDataChangeRequestLine')
DROP TABLE [dbo].[tblstgVeevaDataChangeRequestLine]
GO

/****** Object:  Table [dbo].[tblstgVeevaDataChangeRequest]    Script Date: 10/11/2019 4:32:13 PM ******/
if exists (select name from sys.objects where name='tblstgVeevaDataChangeRequest')
DROP TABLE [dbo].[tblstgVeevaDataChangeRequest]
GO

/****** Object:  Table [dbo].[tblstgVeevaAccountDCR]    Script Date: 10/11/2019 4:32:13 PM ******/
if exists (select name from sys.objects where name='tblstgVeevaAccountDCR')
DROP TABLE [dbo].[tblstgVeevaAccountDCR]
GO

/****** Object:  Table [dbo].[tblstgVeevaAccountDCR]    Script Date: 10/11/2019 4:32:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblstgVeevaAccountDCR](
	[Id] [nvarchar](68) NULL,
	[PRIMARY_PARENT_VOD__C] [nvarchar](max) NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tblstgVeevaDataChangeRequest]    Script Date: 10/11/2019 4:32:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblstgVeevaDataChangeRequest](
	[Id] [nvarchar](68) NULL,
	[Notes_vod__c] [varchar](255) NULL,
	[resolution_note_vod__c] [varchar](255) NULL,
	[result_vod__c] [varchar](21) NOT NULL,
	[Status_vod__c] [varchar](9) NOT NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[tblstgVeevaDataChangeRequestLine]    Script Date: 10/11/2019 4:32:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblstgVeevaDataChangeRequestLine](
	[Id] [nvarchar](68) NULL,
	[resolution_note_vod__c] [varchar](255) NOT NULL,
	[Result_vod__c] [varchar](21) NOT NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY]
GO


