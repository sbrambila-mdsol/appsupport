USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[CustomerInstanceAuditError]    Script Date: 4/14/2020 11:24:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CustomerInstanceAuditError](
	[AuditErrorId] [int] IDENTITY(1,1) NOT NULL,
	[InstanceId] [int] NOT NULL,
	[AuditDate] [date] NOT NULL,
	[ErrorMessage] [nvarchar](4000) NULL,
PRIMARY KEY CLUSTERED 
(
	[AuditErrorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
