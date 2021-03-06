USE [ApplicationServices_IM]
GO
/****** Object:  Table [dbo].[tbldf_CloudHealthMonthlyAWSCostAllocation]    Script Date: 4/13/2020 3:15:04 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[tbldf_CloudHealthMonthlyAWSCostAllocation](
	[InvoiceID] [varchar](500) NULL,
	[PayerAccountId] [varchar](500) NULL,
	[LinkedAccountId] [varchar](500) NULL,
	[RecordType] [varchar](500) NULL,
	[RecordID] [varchar](500) NULL,
	[BillingPeriodStartDate] [varchar](500) NULL,
	[BillingPeriodEndDate] [varchar](500) NULL,
	[InvoiceDate] [varchar](500) NULL,
	[PayerAccountName] [varchar](500) NULL,
	[LinkedAccountName] [varchar](500) NULL,
	[TaxationAddress] [varchar](500) NULL,
	[PayerPONumber] [varchar](500) NULL,
	[ProductCode] [varchar](500) NULL,
	[ProductName] [varchar](500) NULL,
	[SellerOfRecord] [varchar](500) NULL,
	[UsageType] [varchar](500) NULL,
	[Operation] [varchar](500) NULL,
	[AvailabilityZone] [varchar](500) NULL,
	[RateId] [varchar](500) NULL,
	[ItemDescription] [varchar](500) NULL,
	[UsageStartDate] [varchar](500) NULL,
	[UsageEndDate] [varchar](500) NULL,
	[UsageQuantity] [varchar](500) NULL,
	[BlendedRate] [varchar](500) NULL,
	[CurrencyCode] [varchar](500) NULL,
	[CostBeforeTax] [varchar](500) NULL,
	[Credits] [varchar](500) NULL,
	[TaxAmount] [varchar](500) NULL,
	[TaxType] [varchar](500) NULL,
	[TotalCost] [varchar](500) NULL,
	[userClient] [varchar](500) NULL,
	[userDescription] [varchar](500) NULL,
	[userName] [varchar](500) NULL,
	[userProject] [varchar](500) NULL,
	[userSQL] [varchar](500) NULL,
	[userSQLVersion] [varchar](500) NULL
) ON [PRIMARY]
GO
