USE [<customer>_TSK_IM]--change to customer
GO

IF EXISTS (SELECT NAME FROM sys.tables WHERE name = 'tbldf_CommandCenterUsers')
DROP TABLE [dbo].[tbldf_CommandCenterUsers]
GO

/****** Object:  Table [dbo].[tbldf_CommandCenterUsers]    Script Date: 11/15/2019 1:03:01 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tbldf_CommandCenterUsers](
	[AuthID] [nvarchar](512) NULL,
	[Email] [nvarchar](512) NULL,
	[RoleID] [nvarchar](512) NULL,
	[DisplayName] [nvarchar](512) NULL
) ON [PRIMARY]
GO

--select * from tbldf_CommandCenterUsers