
--Creating the Valid Staging tables

use VERASTEM_IM
go


if exists (select name from sys.objects where name='tblstgVeevaSpecialtyDCRValid')
DROP TABLE [dbo].[tblstgVeevaSpecialtyDCRValid]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblstgVeevaSpecialtyDCRValid](
	[Id] [nvarchar](68) NULL,
	[Specialty_1_vod__c] [nvarchar](max) NULL,
	[Valid] [int] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO