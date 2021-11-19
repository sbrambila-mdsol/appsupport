--Creating the Base Staging Table

use VERASTEM 
go 

if exists (select name from sys.objects where name='tblstgVeevaSpecialtyDCR')
DROP TABLE [dbo].[tblstgVeevaSpecialtyDCR]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblstgVeevaSpecialtyDCR](
	[Id] [nvarchar](68) NULL,
	[Specialty_1_vod__c] [nvarchar](max) NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


