USE [BLUEPRINT]
GO

IF OBJECT_ID('uspPrometricAddressAgainstMaster','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspPrometricAddressAgainstMaster]
GO

/****** Object:  StoredProcedure [dbo].[uspPrometricAddressAgainstMaster]    Script Date: 6/8/2020 11:06:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspPrometricAddressAgainstMaster]
/*******************************************************************************************
Purpose:	To compare the latest ship address from Prometrics vs. the Master address for each NPI number of a Prescriber
Inputs:		
Author:		Todd Forman
Created:	6/8/2020
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspPrometricAddressAgainstMaster
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM 
					
					---- Staging Tables:
						SELECT * FROM 

					---- Reporting Tables:
						select * from dbo.tblPrometricsAddressComparison where statematch ='n'
						select * from dbo.tblPrometricsAddressComparison where zipmatch ='n'
						select * from dbo.tblPrometricsAddressComparison where terrmatch ='n'
						



*******************************************************************************************/

AS
BEGIN
	SET NOCOUNT ON 
	-----------
	--Logging
	-----------	
	INSERT INTO AGD.tblMdParentStoreProcedure
	SELECT @@PROCID, (SELECT AGD.udfGetStoreProcedure(@@PROCID))
	
	DECLARE @tblDataRunLog AS AGD.typDataRunLog
	INSERT INTO @tblDataRunLog  
	SELECT * FROM AGD.udfGetDataRunLogTable (2, @@PROCID,null) ---The 2 is the TPSExecProcesTypeId which represents logging for store procedure
	
	--------
	--Place code in between Code Start and Code End
	--------
	------
	--Code Start
	--------
	BEGIN TRY
		-----------combine latest ship records from both feeds
		select 'SP' as TrxSOURCE, pmcTransactionId,BPMPatientID,RecDate,RefDate,RxStatusDate,RxStatusCode,RxSubstatusCode,
				pmcCustId,PresLastName,PresFirstName,PresAddr1,PresAddr2,PresCity,PresState,PresZip,PresNPI,ShipDate,QtyDispensed,PatGender,
				hubPatientId,spPatientId,PrimaryPayerName,PrimaryPayerType,DataDate
		into #full--select *
		from BLUEPRINT_ADHOC.dbo.tbldf_PROM_SP_Transactions
		where rxstatuscode='active' and rxsubstatuscode='Shipment'
		UNION ALL
		select 'hub' as TrxSOURCE, pmcTransactionId,BPMPatientID,RecDate,RefDate,RxStatusDate,RxStatusCode,RxSubstatusCode,
		pmcCustId,PresLastName,PresFirstName,PresAddr1,PresAddr2,PresCity,PresState,PresZip,PresNPI,ShipDate,QtyDispensed,PatGender,
			hubPatientId,spPatientId,PrimaryPayerName,PrimaryPayerType,DataDate
		from BLUEPRINT_ADHOC.dbo.tbldf_PROM_Hub_Transactions
		where rxstatuscode='active' and rxsubstatuscode='Shipment'
		order by PresNPI

		--find latest recdate
		select presnpi,max(recdate) as recdate
		into #maxship
		from #full 
		--where presnpi='1003869413'
		group by presnpi

		--latest recdate listed out with address
		select f.presnpi,f.recdate,f.PresAddr1,f.PresAddr2,f.PresCity,F.PresState,F.PresZip
		into #MaxShipwithAddress
		from #maxship as m
			inner join #full as f on m.presnpi = f.presnpi and m.recdate=f.recdate
		group by f.presnpi,f.recdate,f.PresAddr1,f.PresAddr2,f.PresCity,F.PresState,F.PresZip
		order by presnpi

		truncate table dbo.tblPrometricsAddressComparison
		insert into dbo.tblPrometricsAddressComparison
		select
		case when h.state = m.presState then 'Y' else 'N' end as StateMatch, 
		case when h.zip5 = m.preszip then 'Y' else 'N' end as ZipMatch,
		case when PMZT.TerritoryCode = STZT.TerritoryCode then 'Y' else 'N' end as TerrMatch,
			h.bpm_hcp_id,h.npinumber,h.FirstName,h.MiddleInitial,H.LastName,H.AddressLine1 as MasterAddress1,H.AddressLine2 as MasterAddress2,
			H.City as MasterCity,H.State as MasterState,H.Zip5 as MasterZip,H.ActiveVeevaId,
			m.PresAddr1 as PrometricsAddress1,m.PresAddr2 as PrometricsAddress2,M.PresCity as PrometricsCity,M.PresState as PrometricsState,
			M.PresZip as PrometricsZip,PMZT.TerritoryCode as PromTerrCD,STZT.TerritoryCode as MasterTerrCD,m.Recdate
		from BLUEPRINT_ADHOC.dbo.tblShyft_HCPMaster as h
			inner join #MaxShipwithAddress as m on h.NPINumber=m.presnpi
			inner join BLUEPRINT_ADHOC.dbo.tbldf_Blueprint_ZipTerr PMZT on m.PresZip=PMZT.zip
			inner join BLUEPRINT_ADHOC.dbo.tbldf_Blueprint_ZipTerr STZT on h.Zip5=STZT.zip
		where PMZT.FieldForceName like 'ABM%' and STZT.FieldForceName like 'ABM%'
		
	END TRY
	--------
	--Code End
	--------	
	
	-----------
	--Logging
	-----------	
	BEGIN CATCH
		----------
		--Update table variable with error message
		----------					   
		UPDATE @tblDataRunLog 
		SET ErrorMessage=ERROR_MESSAGE() 
                + ' Line:' + CONVERT(VARCHAR,ERROR_LINE())
                + ' Error#:' + CONVERT(VARCHAR,ERROR_NUMBER())
                + ' Severity:' + CONVERT(VARCHAR,ERROR_SEVERITY())
                + ' State:' + CONVERT(VARCHAR,ERROR_STATE())
                + ' user:' + SUSER_NAME()
                + ' in proc:' + ISNULL(ERROR_PROCEDURE(),'N/A')
			 + CASE WHEN OBJECT_NAME(@@PROCID) <> ERROR_PROCEDURE() THEN '<--' + OBJECT_NAME(@@PROCID) ELSE '' END   -- will display error from sub stored procedures
		  , ErrorNumber =ERROR_NUMBER()

	END CATCH

	----------
	--Log
	----------					   		   	
	EXEC AGD.uspInsertDataRunLog  @tblDataRunLog, 1 -----AGD.uspInsertDataRunLog will raise error if there was an error



END

GO


