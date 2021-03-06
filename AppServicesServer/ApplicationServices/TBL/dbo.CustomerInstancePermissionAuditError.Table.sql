USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[CustomerInstancePermissionAuditError]    Script Date: 4/14/2020 11:24:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerInstancePermissionAuditError](
	[PermissionAuditErrorId] [int] IDENTITY(1,1) NOT NULL,
	[InstanceId] [int] NOT NULL,
	[AuditDate] [date] NOT NULL,
	[DBName] [varchar](128) NULL,
	[SQLStmt] [nvarchar](max) NULL,
	[ErrorMessage] [nvarchar](4000) NULL,
PRIMARY KEY CLUSTERED 
(
	[PermissionAuditErrorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
