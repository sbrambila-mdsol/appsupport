

USE TPS_DBA
	DROP TABLE IF EXISTS TPS_DBA.dbo.tblMdVendorScenarioMap; 
	CREATE TABLE TPS_DBA.dbo.tblMdVendorScenarioMap ([Id] [int] IDENTITY(1,1) NOT NULL, [TPSScenarioTypeID] [varchar](MAX) NOT NULL,	[DataFeedDescription] [varchar](MAX) NULL,	[VendorName] [varchar](MAX) NULL,	[Addressee] [varchar](MAX) NULL,	[VendorEmail] [varchar](MAX) NOT NULL,	[ClientEmail] [varchar](MAX) NULL,	[SHYFTEmail] [varchar](MAX) NULL,	[ReplyTo] [varchar](MAX) NULL,	[CopyRecipients] [varchar](MAX) NULL,	[BlindCopyRecipients] [varchar](MAX) NULL,	[VendorSpecificMessage] [varchar](MAX) NULL, [Active] bit,	[InsertDate] [datetime] NULL)
	ALTER TABLE dbo.tblMdVendorScenarioMap ADD  DEFAULT (getdate()) FOR [InsertDate]
	ALTER TABLE dbo.tblMdVendorScenarioMap ADD  DEFAULT 1 FOR [Active]
	ALTER TABLE dbo.tblMdVendorScenarioMap ADD  DEFAULT 'shyftapplicationservices@medidata.com' FOR [ReplyTo]
	ALTER TABLE dbo.tblMdVendorScenarioMap ADD  DEFAULT 'shyftapplicationservices@medidata.com' FOR [SHYFTEmail]


	--Additional columns 
	FileDateLogicColumn
	WhenToNotIgnoreFileNotFound
	SELECT * FROM tps_dba.dbo.tblserversetting where SettingName like 'sendvendoremails'
	ALTER TABLE TPS_DBA.dbo.tblMdVendorScenarioMap ALTER COLUMN CopyRecipients Varchar(1000)
	--Insert into TPS_DBA.dbo.tblMdVendorScenarioMap (TPSScenarioTypeID,	DataFeedDescription,	VendorName,	Addressee,	VendorEmail,	ClientEmail,	SHYFTEmail,	ReplyTo,	CopyRecipients,	BlindCopyRecipients,	VendorSpecificMessage)
	SELECT * FROM TPS_DBA.dbo.tblMdVendorScenarioMap
	order by vendorname desc
	dpennington
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  VendorSpecificMessage = ''
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  VendorSpecificMessage = NULL
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  Addressee = 'Dave'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  Addressee = 'Amber Team' where VendorName like 'amber'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  Addressee = 'Walgreens Team' where VendorName like 'Walgreens'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  Addressee = 'Acaria Team' where VendorName like 'Acaria'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  Addressee = 'Accredo Team' where VendorName like 'Accredo'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  Addressee = 'CVS Team' where VendorName like 'CVS'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  VendorEmail = 'cromeo@shyftanalytics.com' WHERE VendorName LIKE 'AMBER'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  VendorEmail = 'kmartinek@shyftanalytics.com'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  VendorEmail = '' where vendorname not in ('amber', 'accredo')
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  VendorEmail = 'nruhl@shyftanalytics.com'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  VendorEmail = 'afennessy@shyftanalytics.com'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  VendorEmail = 'afennessy@shyftanalytics.com'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  CopyRecipients = 'afennessy@shyftanalytics.com; nruhl@shyftanalytics.com; kmartinek@shyftanalytics.com' WHERE VendorName LIKE 'AMBER'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  SHYFTEmail = 'shyftapplicationservices@medidata.com'
	update TPS_DBA.dbo.tblMdVendorScenarioMap set  ReplyTo = 'shyftapplicationservices@medidata.com'

	--update TPS_DBA.dbo.tblMdVendorScenarioMap set SHYFTEmail = 'afennessy@shyftanalytics.com', ReplyTo = 'afennessy@shyftanalytics.com'  , active = 1

IF NOT EXISTS (SELECT * FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SendVendorEmails')
  BEGIN
    INSERT INTO TPS_DBA.dbo.tblServerSetting (SettingDescription, SettingName, SettingValue)
    VALUES ('Binary flag to send late file emails externally', 'SendVendorEmails', '1')
  END

IF NOT EXISTS (SELECT * FROM GREENWICH.agd.tblMdSetting WHERE Settingname = 'DataDateLogic')
	BEGIN 
		INSERT INTO GREENWICH.agd.tblMdSetting (SettingDescription, SettingName, SettingValue)
		VALUES ('Number of days behind current day that Database DataDate is set to during normal operations', 'DataDateLogic', '1') 	
	END
	 

	SELECT * FROM GREENWICH.agd.tblMdDatafeedImportlog where filepath like '%amber%' order by Importid desc
	SELECT * FROM GREENWICH.agd.tblMdDatafeedImportlog WHERE IMPORTID = 33253 order by Importid desc
SELECT distinct top 1 TPSRunID, TPSScenarioTypeID FROM greenwich.agd.tblmddatarunlog where TPSScenarioTypeId IN (9543)  ORDER BY TPSRunID desc
	
	update GREENWICH.agd.tblMdDatafeedImportlog set ImportedDate = '2019-04-23 10:15:09.853' WHERE IMPORTID = 33253
	update GREENWICH.agd.tblMdDatafeedImportlog set RunID = 16979 WHERE IMPORTID = 33253
	update GREENWICH.agd.tblmddatarunlog set TPSRunID = 16979 WHERE TPSProcessLogID in
	(462823
,462824
,462825
,462826
,462827
,462828
,462829
,462830
)

	update GREENWICH.agd.tblMdDatafeedImportlog a 
	set RunID where 

	SELECT * FROM greenwich.agd.tblmddatarunlog where TPSRunID = 16747 ORDER BY TPSRunID desc
SELECT distinct top 1 TPSRunID, TPSScenarioTypeID FROM greenwich.agd.tblmddatarunlog where TPSScenarioTypeId IN (9543)  ORDER BY TPSRunID desc
DROP TABLE IF EXISTS #RunIds
				CREATE TABLE #RunIds (TPSRunId int, TPSScenarioTypeID int) 
				DROP TABLE IF EXISTS #tblMdVendorScenarioMapRanked
				SELECT PrimaryRank=RANK() OVER (PARTITION BY VendorName ORDER BY TPSScenarioTypeId), * INTO #tblMdVendorScenarioMapRanked  FROM TPS_DBA.dbo.tblMdVendorScenarioMap
				SELECT * FROM #tblMdVendorScenarioMapRanke
SELECT distinct top 1 TPSRunID, TPSScenarioTypeID FROM greenwich.agd.tblmddatarunlog where TPSScenarioTypeId IN (9543)  ORDER BY TPSRunID desc
SELECT distinct top 1 TPSRunID, TPSScenarioTypeID FROM greenwich.agd.tblmddatarunlog where TPSScenarioTypeId = (SELECT TPSScenarioTypeId FROM #tblMdVendorScenarioMapRanked WHERE VendorName = 'amber' AND PrimaryRank = 1) ORDER BY TPSRunID desc

select * from x
update y

select * from y

rollback tran

	BEGIN TRAN
			SELECT * FROM 
			WHERE 

			UPDATE	MPP
			SET		--MPP.ImportedDate	= MPPBACK.ImportedDate
			--	SELECT	*
			FROM	# MPP
			--JOIN	greenwich_20190423.agd.tblMdDatafeedImportlog MPPBACK ON MPP.Importid = MPPBACK.Importid --
			WHERE 	
			
			SELECT * FROM 
			WHERE 
	END TRAN
	
	update GREENWICH.agd.tblMdDatafeedImportlog set ImportedDate = '2019-04-19 10:15:09.853' WHERE IMPORTID = 33253
	update GREENWICH.agd.tblMdDatafeedImportlog set RunID = 16747 WHERE IMPORTID = 33253
	update GREENWICH.agd.tblmddatarunlog set TPSRunID = 16747 WHERE TPSProcessLogID in
	(462823
,462824
,462825
,462826
,462827
,462828
,462829
,462830
)


	BEGIN TRAN
			SELECT * FROM 
			WHERE 

			UPDATE	MPP
			SET		--MPP.ImportedDate	= MPPBACK.ImportedDate
			--	SELECT	*
			FROM	 MPP
			--JOIN	greenwich_20190423.agd.tblMdDatafeedImportlog MPPBACK ON MPP.Importid = MPPBACK.Importid --
			WHERE 	
			
			SELECT * FROM 
			WHERE 
	END TRAN

UPDATE 
SET
WHERE
	