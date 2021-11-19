USE [ApplicationServices_IM]
GO

DROP TABLE IF EXISTS [dbo].[tbldfOpenAirHours] 
GO 
/****** Object:  Table [dbo].[tbldfOpenAirHours]    Script Date: 5/3/2019 4:46:51 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbldfOpenAirHours](
	[YearMth] [nvarchar](10) NULL,
	[Date] [nvarchar](10) NULL,
	[Client] [nvarchar](60) NULL,
	[Project] [nvarchar](70) NULL,
	[Task] [nvarchar](80) NULL,
	[TimeHrMin] [nvarchar](30) NULL,
	[Hours] [nvarchar](10) NULL,
	[Firstname] [nvarchar](20) NULL,
	[Lastname] [nvarchar](20) NULL
) ON [PRIMARY]

GO
