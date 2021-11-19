USE [ApplicationServices_IM]
GO

IF EXISTS (SELECT OBJECT_ID FROM SYS.TABLES WHERE NAME='AllProdIssueTickets_Daily') DROP TABLE dbo.AllProdIssueTickets_Daily

/****** Object:  Table [dbo].[AllProdIssueTickets_Daily]    Script Date: 5/17/2019 4:21:53 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[AllProdIssueTickets_Daily](
	[Key] [nvarchar](255) NULL,
	[Project] [nvarchar](255) NULL,
	[Summary] [nvarchar](255) NULL,
	[Status] [nvarchar](255) NULL,
	[Client_Facing] [nvarchar](255) NULL,
	[Identified_By] [nvarchar](255) NULL,
	[Source] [nvarchar](255) NULL,
	[ProdIssueRootCause] [nvarchar](max) NULL,
	[TypeofIssue] [nvarchar](255) NULL,
	[IssuePriority] [nvarchar](255) NULL,
	[Created] [nvarchar](255) NULL,
	[Updated] [nvarchar](255) NULL,
	ResolutionDate [nvarchar](255) NULL,
	Resolution nvarchar(max) null,
	ResolutionSteps nvarchar(max) null,
	IssueDesc nvarchar(max) null,
	[EscalatedtoTech] [nvarchar](255) NULL,
	[RunLate] [nvarchar](255) NULL,
	[SLA] [nvarchar](255) NULL,
	[Assignee] [nvarchar](255) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO


