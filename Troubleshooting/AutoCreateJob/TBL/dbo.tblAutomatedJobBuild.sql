USE [TPS_DBA]
GO

IF EXISTS (SELECT NAME FROM sys.tables WHERE name = 'tblAutomatedJobBuild')
DROP TABLE [dbo].[tblAutomatedJobBuild]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tblAutomatedJobBuild](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[jobname] [varchar](255) NULL
) ON [PRIMARY]
GO


