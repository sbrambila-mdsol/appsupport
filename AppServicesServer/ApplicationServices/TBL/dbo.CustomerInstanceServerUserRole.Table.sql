USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[CustomerInstanceServerUserRole]    Script Date: 4/14/2020 11:24:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerInstanceServerUserRole](
	[ServerUserRoleId] [int] IDENTITY(1,1) NOT NULL,
	[InstanceId] [int] NOT NULL,
	[AuditDate] [date] NOT NULL,
	[SystemID] [int] NOT NULL,
	[LoginName] [varchar](128) NULL,
	[DefaultDatabase] [varchar](128) NULL,
	[LoginType] [varchar](128) NULL,
	[ADLoginType] [varchar](128) NULL,
	[sysadmin] [bit] NULL,
	[securityadmin] [bit] NULL,
	[serveradmin] [bit] NULL,
	[setupadmin] [bit] NULL,
	[processadmin] [bit] NULL,
	[diskadmin] [bit] NULL,
	[dbcreator] [bit] NULL,
	[bulkadmin] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[ServerUserRoleId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
