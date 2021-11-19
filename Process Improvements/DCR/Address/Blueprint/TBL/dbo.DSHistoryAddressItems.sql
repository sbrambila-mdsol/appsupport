USE [BLUEPRINT]
GO

if exists (select name from sys.objects where name='DSHistoryAddressItems')
DROP TABLE [dbo].[DSHistoryAddressItems]
GO


/****** Object:  Table [dbo].[DSHistoryAddressItems]    Script Date: 6/15/2020 10:09:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DSHistoryAddressItems](
	[TaskNo] [int] NULL,
	[RowNo] [int] IDENTITY(1,1) NOT NULL,
	[DescriptionType] [varchar](255) NULL,
	[VeevaID] [varchar](18) NULL,
	[RecordType] [varchar](255) NULL,
	[DateAdded] [date] NULL,
	[DateCompleted] [date] NULL,
	[CompletedBy] [varchar](100) NULL,
	[VeevaAddressID] [varchar](18) NULL,
	[Address1] [varchar](255) NULL,
	[Address2] [varchar](255) NULL,
	[City] [varchar](255) NULL,
	[State] [varchar](255) NULL,
	[Zip] [varchar](255) NULL,
	[Approved] [varchar](1) NULL,
	[Notes] [varchar](255) NULL
) ON [PRIMARY]
GO


