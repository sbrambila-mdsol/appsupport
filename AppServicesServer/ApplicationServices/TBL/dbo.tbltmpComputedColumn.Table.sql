USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tbltmpComputedColumn]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbltmpComputedColumn](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[DropScript] [nvarchar](281) NULL,
	[AddScript] [nvarchar](max) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
