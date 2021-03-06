USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[Failed_Queries]    Script Date: 4/14/2020 11:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Failed_Queries](
	[ID] [nvarchar](50) NOT NULL,
	[DatabaseName] [int] NOT NULL,
	[SchemaName] [nvarchar](150) NOT NULL,
	[ObjectName] [nvarchar](1) NULL,
	[ObjectType] [nvarchar](1) NULL,
	[IndexName] [nvarchar](1) NULL,
	[IndexType] [nvarchar](1) NULL,
	[StatisticsName] [nvarchar](1) NULL,
	[PartitionNumber] [nvarchar](1) NULL,
	[ExtendedInfo] [nvarchar](1) NULL,
	[Command] [nvarchar](1) NULL,
	[CommandType] [nvarchar](1) NULL,
	[StartTime] [nvarchar](1) NULL,
	[EndTime] [nvarchar](1) NULL,
	[ErrorNumber] [nvarchar](1) NULL,
	[ErrorMessage] [nvarchar](1) NULL
) ON [PRIMARY]
GO
