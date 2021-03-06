USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[BudgetMaster]    Script Date: 4/13/2020 3:15:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BudgetMaster](
	[Customer] [nvarchar](255) NULL,
	[Type] [nvarchar](255) NULL,
	[GroupType] [nvarchar](255) NULL,
	[Mar-20] [float] NULL,
	[Apr-20] [float] NULL,
	[May-20] [float] NULL,
	[Jun-20] [float] NULL,
	[Jul-20] [float] NULL,
	[Aug-20] [float] NULL,
	[Sep-20] [float] NULL,
	[Oct-20] [float] NULL,
	[Nov-20] [float] NULL,
	[Dec-20] [float] NULL,
	[Jan-21] [float] NULL,
	[Feb-21] [float] NULL,
	[Mar-21] [float] NULL,
	[Apr-21] [float] NULL,
	[May-21] [float] NULL,
	[Jun-21] [float] NULL,
	[Jul-21] [float] NULL,
	[Aug-21] [float] NULL,
	[Sep-21] [float] NULL
) ON [PRIMARY]
GO
