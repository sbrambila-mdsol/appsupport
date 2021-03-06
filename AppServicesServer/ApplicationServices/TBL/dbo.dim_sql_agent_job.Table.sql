USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[dim_sql_agent_job]    Script Date: 4/14/2020 11:24:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dim_sql_agent_job](
	[dim_sql_agent_job_Id] [int] IDENTITY(1,1) NOT NULL,
	[Sql_Agent_Job_Id] [uniqueidentifier] NOT NULL,
	[Sql_Agent_Job_Name] [nvarchar](128) NOT NULL,
	[Job_Create_Datetime] [datetime] NOT NULL,
	[Job_Last_Modified_Datetime] [datetime] NOT NULL,
	[Is_Enabled] [bit] NOT NULL,
	[Is_Deleted] [bit] NOT NULL,
 CONSTRAINT [PK_dim_sql_agent_job] PRIMARY KEY CLUSTERED 
(
	[dim_sql_agent_job_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
