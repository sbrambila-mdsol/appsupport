USE [BLUEPRINT]
GO

if exists (select name from sys.objects where name='DSHistoryDCRItems')
DROP TABLE [dbo].[DSHistoryDCRItems]
GO

/****** Object:  Table [dbo].[DSHistoryDCRItems]    Script Date: 6/29/2020 11:54:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DSHistoryDCRItems](
	[Id] [nvarchar](68) NULL,
	[Name] [nvarchar](130) NULL,
	[RecordTypeId] [nvarchar](68) NULL,
	[CreatedDate] [date] NULL,
	[Notes_vod__c] [nvarchar](305) NULL,
	[Status_vod__c] [nvarchar](305) NULL,
	[LastModifiedDate] [date] NULL,
	[LastModifiedById] [nvarchar](68) NULL
) ON [PRIMARY]
GO


