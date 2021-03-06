USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblAppSrv_JIRASummary]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblAppSrv_JIRASummary](
	[Customer] [nvarchar](255) NULL,
	[projectcount] [int] NULL,
	[c7dRefreshes] [int] NULL,
	[c7dLateRefreshes] [int] NULL,
	[LateRefreshThreshold] [int] NOT NULL,
	[c7dProductionIssues] [int] NULL,
	[p7dProductionIssues] [int] NULL,
	[c7dCustomerFacingIssues] [int] NULL,
	[p7dCustomerFacingIssues] [int] NULL,
	[c7dSHYFTIssues] [int] NULL,
	[c7dnonSHYFTIssues] [int] NULL,
	[OpenProductionIssues] [int] NULL,
	[c1moplusOpenProductionBugs] [int] NULL,
	[p1moplusOpenProductionBugs] [int] NULL,
	[OpenIssuesThreshold] [int] NOT NULL,
	[c13wProductionIssues] [int] NULL,
	[avg13wProductionIssues] [numeric](17, 0) NULL,
	[projectorderOverride] [int] NOT NULL
) ON [PRIMARY]
GO
