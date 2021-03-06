USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[LinkedServer]    Script Date: 4/14/2020 11:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LinkedServer](
	[ServerId] [int] IDENTITY(1,1) NOT NULL,
	[ServerName] [varchar](100) NULL,
	[ServerType] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[ServerId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
