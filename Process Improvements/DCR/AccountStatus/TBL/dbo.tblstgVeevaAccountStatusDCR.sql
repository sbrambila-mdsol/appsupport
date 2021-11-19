USE [VERASTEM]
GO

if exists (select name from sys.objects where name='tblstgVeevaAccountStatusDCR')
DROP TABLE [dbo].[tblstgVeevaAccountStatusDCR]
GO


CREATE TABLE [dbo].[tblstgVeevaAccountStatusDCR](
	[Id] [nvarchar](68) NULL,
	[Account_Status__c] [nvarchar](max) NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


