USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[TBLUSERANALYSIS]    Script Date: 4/14/2020 11:24:09 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TBLUSERANALYSIS](
	[Server Name] [nvarchar](256) NULL,
	[USERNAME] [varchar](50) NULL,
	[UserTypeDescription] [varchar](50) NULL
) ON [PRIMARY]
GO
