USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[tblJIRACustomerMapping]    Script Date: 4/14/2020 11:24:08 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tblJIRACustomerMapping](
	[Project] [nvarchar](255) NULL,
	[JIRAProject] [nvarchar](255) NULL
) ON [PRIMARY]
GO
