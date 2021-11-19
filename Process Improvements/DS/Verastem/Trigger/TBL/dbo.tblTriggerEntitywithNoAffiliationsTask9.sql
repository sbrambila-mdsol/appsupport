USE VERASTEM
GO

IF EXISTS (SELECT name FROM sys.objects WHERE name='tblTriggerEntitywithNoAffiliationsTask9')
DROP TABLE [dbo].[tblTriggerEntitywithNoAffiliationsTask9]
GO

CREATE TABLE dbo.tblTriggerEntitywithNoAffiliationsTask9 (
	HCPEntityID VARCHAR(100),
	FirstName VARCHAR(150),
	LastName VARCHAR(255),
	VeevaID VARCHAR(18),
	SpecialtyFlag VARCHAR(2),
	AffiliationID VARCHAR(255),
	InsertDate VARCHAR(25),
	[Date_Completed] [varchar](255) NULL,
	[Completed_by] [varchar](255) NULL)