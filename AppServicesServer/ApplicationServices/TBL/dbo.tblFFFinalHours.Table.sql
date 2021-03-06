USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblFFFinalHours]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblFFFinalHours](
	[YearMth] [varchar](7) NULL,
	[Date] [date] NULL,
	[Client] [varchar](255) NULL,
	[Project] [nvarchar](255) NULL,
	[Task] [nvarchar](255) NULL,
	[TimeHrMin] [float] NULL,
	[Hours] [float] NULL,
	[FirstName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NULL
) ON [PRIMARY]
GO
