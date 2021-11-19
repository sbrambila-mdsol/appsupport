USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[Customers]    Script Date: 4/14/2020 11:24:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[ID] [smallint] IDENTITY(1,1) NOT NULL,
	[Customer] [nvarchar](255) NULL,
	[OnProdTm] [varchar](2) NOT NULL,
	[Team] [varchar](50) NULL,
	[CustAbb] [varchar](255) NULL
) ON [PRIMARY]
GO
