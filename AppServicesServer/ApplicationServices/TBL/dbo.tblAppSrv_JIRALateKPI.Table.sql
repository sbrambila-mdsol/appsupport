USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblAppSrv_JIRALateKPI]    Script Date: 4/14/2020 11:24:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAppSrv_JIRALateKPI](
	[c7dSHYFTLateRefreshKPI] [int] NULL,
	[p7dSHYFTLateRefreshKPI] [int] NULL,
	[c7dNONSHYFTLateRefreshKPI] [int] NULL,
	[p7dNONSHYFTLateRefreshKPI] [int] NULL
) ON [PRIMARY]
GO
