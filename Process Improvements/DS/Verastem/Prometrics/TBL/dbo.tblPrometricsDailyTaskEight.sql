USE [VERASTEM]
GO

IF EXISTS (SELECT name FROM sys.objects WHERE name='tblPrometricsDailyTaskEight')
DROP TABLE [dbo].[tblPrometricsDailyTaskEight]
GO


/****** Object:  Table [dbo].[tblPrometricsDailyTaskEight]    Script Date: 6/26/2020 9:44:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblPrometricsDailyTaskEight](
	[CUSTID] [varchar](255) NULL,
	[CUSTFULLNAME] [varchar](255) NULL,
	[ENTITYID] [int] NULL,
	[VEEVAID] [varchar](18) NULL,
	[PRIMARY_PARENT] [varchar](255) NULL,
	[CUSTINSERTDATE] [datetime] NULL,
	[MATCHED] [varchar](5) NULL,
	[NOTES] [varchar](255) NULL,
	[CUSTTYPE] [varchar](3) NULL,
	[DATE_ENTERED] [date] NULL,
	[ADDITIONALNOTES] [varchar](255) NULL,
	[Date_Completed] [varchar](255) NULL,
	[Completed_by] [varchar](255) NULL
) ON [PRIMARY]
GO


