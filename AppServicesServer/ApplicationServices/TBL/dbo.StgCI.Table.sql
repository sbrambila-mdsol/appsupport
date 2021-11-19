USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[StgCI]    Script Date: 4/14/2020 11:24:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[StgCI](
	[Customer] [nvarchar](255) NULL,
	[InstanceId] [int] NOT NULL,
	[CustomerId] [int] NULL,
	[LinkedServerName] [varchar](100) NULL,
	[InstanceType] [varchar](100) NULL
) ON [PRIMARY]
GO
