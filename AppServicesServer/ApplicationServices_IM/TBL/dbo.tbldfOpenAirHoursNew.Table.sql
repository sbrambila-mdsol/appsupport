USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[tbldfOpenAirHoursNew]    Script Date: 4/13/2020 3:15:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbldfOpenAirHoursNew](
	[Date] [nvarchar](10) NULL,
	[Client] [nvarchar](60) NULL,
	[Project] [nvarchar](70) NULL,
	[Task] [nvarchar](80) NULL,
	[TimeHrMin] [nvarchar](30) NULL,
	[Hours] [nvarchar](10) NULL,
	[UserFirstname] [nvarchar](30) NULL,
	[UserLastname] [nvarchar](30) NULL,
	[Approvalstatus] [nvarchar](30) NULL
) ON [PRIMARY]
GO
