USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblPreviousTesaroProductionRuns]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblPreviousTesaroProductionRuns](
	[Issue key] [nvarchar](255) NULL,
	[Custom field (Customer (CS))] [nvarchar](255) NULL,
	[Summary] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[Created] [datetime] NULL,
	[Resolved] [datetime] NULL,
	[Sprint] [nvarchar](255) NULL,
	[Custom field (Epic Link)] [nvarchar](255) NULL,
	[Custom field (Escalation to Project Team on Production Issue)] [nvarchar](255) NULL,
	[Custom field (Issue-Free Run)] [nvarchar](255) NULL,
	[Custom field (On Time Delivery)] [nvarchar](255) NULL,
	[WeekEnding] [date] NULL
) ON [PRIMARY]
GO
