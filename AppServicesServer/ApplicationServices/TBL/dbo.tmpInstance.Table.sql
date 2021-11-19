USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tmpInstance]    Script Date: 4/14/2020 11:24:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tmpInstance](
	[InstanceId] [int] IDENTITY(1,1) NOT NULL,
	[LinkedServerName] [varchar](100) NULL,
	[RowNo] [bigint] NULL
) ON [PRIMARY]
GO
