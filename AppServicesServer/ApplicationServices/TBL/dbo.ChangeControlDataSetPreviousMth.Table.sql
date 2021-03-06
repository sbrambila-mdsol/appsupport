USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[ChangeControlDataSetPreviousMth]    Script Date: 4/14/2020 11:24:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ChangeControlDataSetPreviousMth](
	[Key] [nvarchar](max) NULL,
	[Project] [nvarchar](max) NULL,
	[Summary] [nvarchar](max) NULL,
	[Status] [nvarchar](max) NULL,
	[Client_Facing] [nvarchar](max) NULL,
	[Identified_By] [nvarchar](max) NULL,
	[Source] [nvarchar](255) NULL,
	[ProdIssueRootCause] [nvarchar](max) NULL,
	[TypeofIssue] [nvarchar](255) NULL,
	[IssuePriority] [nvarchar](max) NULL,
	[Created] [date] NULL,
	[Updated] [nvarchar](max) NULL,
	[EscalatedtoTech] [nvarchar](255) NULL,
	[RunLate] [nvarchar](255) NULL,
	[SLA] [nvarchar](255) NULL,
	[Assignee] [nvarchar](max) NULL,
	[IssueFree] [nvarchar](255) NULL,
	[ResolutionDate] [nvarchar](max) NULL,
	[Epic] [nvarchar](255) NULL,
	[HoursSpent] [decimal](38, 4) NULL,
	[IssueCount] [int] NOT NULL,
	[Critical Tickets] [int] NULL,
	[High Tickets] [int] NULL,
	[Medium Tickets] [int] NULL,
	[Low Tickets] [int] NULL,
	[Planned] [nvarchar](255) NULL,
	[DeployEnv] [nvarchar](255) NULL,
	[Reporter] [nvarchar](max) NULL,
	[Vendor] [nvarchar](255) NULL,
	[HandledBy] [nvarchar](255) NULL,
	[WeekEndingDate] [date] NULL,
	[StartDate] [date] NULL,
	[EndDate] [date] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
