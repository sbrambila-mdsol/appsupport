USE [BLUEPRINT]
GO

if exists (select name from sys.objects where name='stgPotentialMisMatches')
DROP TABLE [dbo].[stgPotentialMisMatches]
GO

/****** Object:  Table [dbo].[stgPotentialMisMatches]    Script Date: 6/29/2020 11:52:47 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[stgPotentialMisMatches](
	[LungTier] [varchar](10) NULL,
	[PMA_Tier] [varchar](255) NULL,
	[GISTTier] [varchar](100) NULL,
	[ShyftMDMID] [nvarchar](100) NULL,
	[Id] [nvarchar](68) NULL,
	[Name] [nvarchar](305) NULL,
	[ADDRESS1] [nvarchar](130) NULL,
	[Address_line_2_vod__c] [nvarchar](150) NULL,
	[City_vod__c] [nvarchar](90) NULL,
	[State_vod__c] [nvarchar](305) NULL,
	[Zip_vod__c] [nvarchar](70) NULL,
	[Primary_Parent_vod__c] [nvarchar](68) NULL,
	[PrimName] [nvarchar](305) NULL,
	[PrimADDRESS1] [nvarchar](130) NULL,
	[PrimAddress2] [nvarchar](150) NULL,
	[PrimCity] [nvarchar](90) NULL,
	[PrimState] [nvarchar](305) NULL,
	[PrimZip] [nvarchar](70) NULL,
	[TerritoryCode] [varchar](255) NULL,
	[PrimTerr] [varchar](255) NULL
) ON [PRIMARY]
GO


