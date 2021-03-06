USE [ApplicationServices]
GO
/****** Object:  Table [dbo].[dim_sql_agent_schedule]    Script Date: 4/14/2020 11:24:05 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[dim_sql_agent_schedule](
	[Schedule_Id] [int] NOT NULL,
	[Schedule_Name] [nvarchar](128) NOT NULL,
	[Is_Enabled] [bit] NOT NULL,
	[Is_Deleted] [bit] NOT NULL,
	[Schedule_Start_Date] [date] NOT NULL,
	[Schedule_End_Date] [date] NOT NULL,
	[Schedule_Occurrence] [varchar](25) NOT NULL,
	[Schedule_Occurrence_Detail] [varchar](256) NULL,
	[Schedule_Frequency] [varchar](256) NULL,
	[Schedule_Created_Datetime] [datetime] NOT NULL,
	[Schedule_Last_Modified_Datetime] [datetime] NOT NULL,
 CONSTRAINT [PK_fact_sql_agent_job_schedule] PRIMARY KEY CLUSTERED 
(
	[Schedule_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
