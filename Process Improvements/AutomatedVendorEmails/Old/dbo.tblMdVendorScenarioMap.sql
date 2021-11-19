USE TPS_DBA
DROP TABLE IF EXISTS TPS_DBA.dbo.tblMdVendorScenarioMap; 
CREATE TABLE TPS_DBA.dbo.tblMdVendorScenarioMap ([Id] [int] IDENTITY(1,1) NOT NULL, [TPSScenarioTypeID] [varchar](MAX) NOT NULL,	[DataFeedDescription] [varchar](MAX) NULL,	[VendorName] [varchar](MAX) NULL,	[Addressee] [varchar](MAX) NULL,	[VendorEmail] [varchar](MAX) NOT NULL,	[ClientEmail] [varchar](MAX) NULL,	[SHYFTEmail] [varchar](MAX) NULL,	[ReplyTo] [varchar](MAX) NULL,	[CopyRecipients] [varchar](MAX) NULL,	[BlindCopyRecipients] [varchar](MAX) NULL,	[VendorSpecificMessage] [varchar](MAX) NULL, [Active] bit,	[InsertDate] [datetime] NULL)
ALTER TABLE dbo.tblMdVendorScenarioMap ADD  DEFAULT (getdate()) FOR [InsertDate]
ALTER TABLE dbo.tblMdVendorScenarioMap ADD  DEFAULT 1 FOR [Active]
ALTER TABLE dbo.tblMdVendorScenarioMap ADD  DEFAULT 'shyftapplicationservices@medidata.com' FOR [ReplyTo]
ALTER TABLE dbo.tblMdVendorScenarioMap ADD  DEFAULT 'shyftapplicationservices@medidata.com' FOR [SHYFTEmail]
