USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblRptSHYFTPlatformSummary]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblRptSHYFTPlatformSummary](
	[CustomerCount] [int] NOT NULL,
	[ClientName] [nchar](100) NULL,
	[DataSource] [nchar](20) NULL,
	[InsertTime] [datetime] NULL,
	[StrataVersion] [nchar](50) NULL,
	[DataDate] [nchar](100) NULL,
	[CurrentSprint] [nchar](10) NULL,
	[MedProAPI_Enabled] [nchar](10) NULL,
	[SF_Configured] [nchar](10) NULL,
	[VeevaNetwork_Configured] [nchar](10) NULL,
	[VeevaNetwork_HCP] [int] NULL,
	[VeevaNetwork_HCO] [int] NULL,
	[IM_RowCount] [int] NULL,
	[IM_UsedSpaceGB] [numeric](36, 1) NULL,
	[ADHOC_RowCount] [int] NULL,
	[ADHOC_UsedSpaceGB] [numeric](36, 1) NULL,
	[HCP_Mastered] [int] NULL,
	[HCO_Mastered] [int] NULL,
	[Patient_Mastered] [int] NULL,
	[Payer_Mastered] [int] NULL,
	[QC_Active] [int] NULL,
	[LumenV3_UserCount] [int] NULL,
	[Veeva_Account] [int] NULL,
	[TotalActiveDataFeeds] [int] NULL,
	[TotalActiveVeevaObjects] [int] NULL,
	[LumenV2_UserCount] [int] NULL,
	[CC_UserCount] [int] NULL,
	[CC_IM_RowCount] [numeric](36, 1) NULL,
	[CC_IM_UsedSpaceGB] [numeric](36, 1) NULL,
	[LumenVersion] [varchar](2) NULL,
	[Lumen_UserCount] [int] NULL,
	[priorTotalActiveDataFeeds] [int] NULL,
	[priorQC_Active] [int] NULL,
	[priorTotalActiveVeevaObjects] [int] NULL,
	[priorVeeva_Account] [int] NULL,
	[priorIM_RowCount] [int] NULL,
	[priorIM_UsedSpaceGB] [numeric](36, 1) NULL,
	[priorADHOC_RowCount] [int] NULL,
	[priorADHOC_UsedSpaceGB] [numeric](36, 1) NULL,
	[priorHCP_Mastered] [int] NULL,
	[priorHCO_Mastered] [int] NULL,
	[priorPatient_Mastered] [int] NULL
) ON [PRIMARY]
GO
