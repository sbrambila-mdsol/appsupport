USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[ContractedHoursbyCustomer]    Script Date: 4/13/2020 3:15:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ContractedHoursbyCustomer](
	[Customer] [nvarchar](255) NULL,
	[ContractedAMSHRs] [float] NULL,
	[ContratedbySUBHRs] [float] NULL,
	[MappingCustomer] [varchar](255) NULL,
	[TableauCustomer] [varchar](255) NULL
) ON [PRIMARY]
GO
