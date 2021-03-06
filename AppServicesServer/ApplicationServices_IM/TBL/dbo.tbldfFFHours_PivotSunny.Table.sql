USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[tbldfFFHours_PivotSunny]    Script Date: 4/13/2020 3:15:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbldfFFHours_PivotSunny](
	[ProjectProjectName] [nvarchar](90) NULL,
	[ReferenceNumber] [nvarchar](70) NULL,
	[Milestone] [nvarchar](50) NULL,
	[Resource] [nvarchar](50) NULL,
	[TimeSheetDate] [date] NULL,
	[TimeSheetHours] [nvarchar](30) NULL
) ON [PRIMARY]
GO
