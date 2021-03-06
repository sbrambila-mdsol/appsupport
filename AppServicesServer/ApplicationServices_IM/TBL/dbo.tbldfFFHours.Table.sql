USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[tbldfFFHours]    Script Date: 4/13/2020 3:15:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbldfFFHours](
	[StartDate] [nvarchar](20) NULL,
	[EndDate] [nvarchar](20) NULL,
	[ProjectAccount] [nvarchar](500) NULL,
	[ProjectProjectName] [nvarchar](80) NULL,
	[ReferenceNumber] [nvarchar](70) NULL,
	[Milestone] [nvarchar](255) NULL,
	[SaturdayHours] [nvarchar](30) NULL,
	[SundayHours] [nvarchar](20) NULL,
	[MondayHours] [nvarchar](20) NULL,
	[TuesdayHours] [nvarchar](30) NULL,
	[WednesdayHours] [nvarchar](30) NULL,
	[ThursdayHours] [nvarchar](30) NULL,
	[FridayHours] [nvarchar](20) NULL,
	[TotalBillableHours] [nvarchar](40) NULL,
	[TotalNonBillableHours] [nvarchar](50) NULL,
	[Resource] [nvarchar](50) NULL,
	[Status] [nvarchar](10) NULL
) ON [PRIMARY]
GO
