USE [BLUEPRINT]
GO

IF EXISTS (SELECT NAME FROM sys.tables WHERE name = 'tblPrometricsAddressComparison')
DROP TABLE [dbo].[tblPrometricsAddressComparison]
GO


/****** Object:  Table [dbo].[tblPrometricsAddressComparison]    Script Date: 6/8/2020 1:14:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblPrometricsAddressComparison](
	[StateMatch] [varchar](1) NOT NULL,
	[ZipMatch] [varchar](1) NOT NULL,
	[TerrMatch] [varchar](1) NOT NULL,
	[bpm_hcp_id] [int] NOT NULL,
	[npinumber] [varchar](300) NULL,
	[FirstName] [varchar](8000) NULL,
	[MiddleInitial] [varchar](300) NULL,
	[LastName] [varchar](8000) NULL,
	[MasterAddress1] [varchar](8000) NULL,
	[MasterAddress2] [varchar](8000) NULL,
	[MasterCity] [varchar](8000) NULL,
	[MasterState] [varchar](300) NULL,
	[MasterZip] [varchar](5) NULL,
	[ActiveVeevaId] [varchar](50) NULL,
	[PrometricsAddress1] [nvarchar](255) NULL,
	[PrometricsAddress2] [nvarchar](255) NULL,
	[PrometricsCity] [nvarchar](255) NULL,
	[PrometricsState] [nvarchar](255) NULL,
	[PrometricsZip] [nvarchar](255) NULL,
	[PromTerrCD] [varchar](255) NULL,
	[MasterTerrCD] [varchar](255) NULL,
	[Recdate] [nvarchar](255) NULL
) ON [PRIMARY]
GO


