USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[CustomerInstance]    Script Date: 4/14/2020 11:24:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerInstance](
	[InstanceId] [int] IDENTITY(1,1) NOT NULL,
	[CustomerId] [int] NULL,
	[LinkedServerName] [varchar](100) NULL,
	[InstanceType] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[InstanceId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
