USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[tblProductionRunTickets_Weekly]    Script Date: 4/13/2020 3:15:05 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblProductionRunTickets_Weekly](
	[Project] [varchar](50) NULL,
	[Issue Type] [varchar](50) NULL,
	[Summary] [varchar](50) NULL,
	[Assignee] [varchar](50) NULL,
	[Epic Link] [varchar](50) NULL,
	[Custom field (Issue-Free Run)] [varchar](50) NULL,
	[Custom Field (On Time Delivery)] [varchar](50) NULL
) ON [PRIMARY]
GO
