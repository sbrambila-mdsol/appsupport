USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[Tasks]    Script Date: 4/13/2020 3:15:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Tasks](
	[TaskID] [int] IDENTITY(1,1) NOT NULL,
	[Task] [varchar](255) NULL,
	[TaskGroupID] [int] NULL,
	[TaskGroup] [varchar](255) NULL,
	[PSFlag] [varchar](1) NULL
) ON [PRIMARY]
GO
