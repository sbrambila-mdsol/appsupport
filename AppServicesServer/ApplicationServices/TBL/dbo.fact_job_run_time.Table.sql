USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[fact_job_run_time]    Script Date: 4/14/2020 11:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fact_job_run_time](
	[Sql_Agent_Job_Run_Instance_Id] [int] NOT NULL,
	[Sql_Agent_Job_Id] [uniqueidentifier] NOT NULL,
	[Job_Start_Datetime] [datetime] NOT NULL,
	[Job_End_Datetime]  AS (dateadd(second,[job_duration_seconds],[Job_Start_Datetime])) PERSISTED,
	[Job_Duration_Seconds] [int] NOT NULL,
	[Job_Status] [varchar](8) NOT NULL,
 CONSTRAINT [PK_fact_job_run_time] PRIMARY KEY CLUSTERED 
(
	[Sql_Agent_Job_Run_Instance_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
