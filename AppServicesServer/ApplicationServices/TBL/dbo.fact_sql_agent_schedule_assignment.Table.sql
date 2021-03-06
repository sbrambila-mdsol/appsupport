USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[fact_sql_agent_schedule_assignment]    Script Date: 4/14/2020 11:24:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fact_sql_agent_schedule_assignment](
	[fact_sql_agent_schedule_assignment_id] [int] IDENTITY(1,1) NOT NULL,
	[Sql_Agent_Job_Id] [uniqueidentifier] NOT NULL,
	[Schedule_Id] [int] NOT NULL,
	[Next_Run_Datetime] [datetime] NULL,
 CONSTRAINT [PK_fact_sql_agent_schedule_assignment] PRIMARY KEY CLUSTERED 
(
	[fact_sql_agent_schedule_assignment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
