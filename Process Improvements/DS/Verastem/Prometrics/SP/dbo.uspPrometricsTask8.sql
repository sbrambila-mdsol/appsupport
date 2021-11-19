USE [VERASTEM]
GO

IF OBJECT_ID('uspPrometricsTask8','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspPrometricsTask8]
GO

/****** Object:  StoredProcedure [dbo].[uspPrometricsTask8]    Script Date: 6/25/2020 11:57:20 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspPrometricsTask8]
/*******************************************************************************************
Purpose:	Affiliation and Supplemental Prometrics HCP's and HCO's
Inputs:		
Author:	Todd Forman	
Created:	6/23/2020
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspPrometricsTask8
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM 
					
					---- Staging Tables:
						SELECT * FROM 

					---- Reporting Tables:
						SELECT * FROM VERASTEM.dbo.tblPrometricsDailyTaskEight
						

--only load where entiry is null or veeva id is null or primary parent is null
--matched M = match confict exception history; S = source conflict exception history
--notes = "ENTITY AND VEEVA NO PRIMARY PARENT" or "ENTITY NO VEEVA"

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
		--hco inserts
		INSERT INTO tblPrometricsDailyTaskEight(CUSTID, CUSTFULLNAME,EntityID, VeevaID, PRIMARY_PARENT,CUSTINSERTDATE,CUSTTYPE,DATE_ENTERED)
		select a.CUSTID, a.CUSTFULLNAME, c.HCOEntityID, d.VeevaID, e.Primary_Parent_vod__c,a.CUSTINSERTDATE,'HCO',CONVERT(DATE,GETDATE())
		from verastem..vwPrometricsCustomerMaster a
			inner join verastem..vwPrometricsCustomerAddressMaster b on a.CUSTID = b.CUST_ID
			left join verastem_cm..vwHCOAlternateID c on a.custid = c.DataProviderUniqueIdentifier
			left join verastem_cm..vwOutletMaster d on c.HCOEntityID = d.HCOEntityID
			left join VERASTEM_IM.dbo.tbldfVeevaAccount e on c.HCOEntityID = e.SHYFT_MDM_EntityID__c
		where CUSTTYPE in ('O', 'O-GPO') and CUST_COUNTRY in ('US', 'USA')
			and (c.HCOEntityID is null OR d.VeevaID IS NULL OR e.Primary_Parent_vod__c IS NULL)
			and CUSTID not in (select CUSTID from tblPrometricsDailyTaskEight where DATE_ENTERED = convert(date,GETDATE()))
		order by CUSTINSERTDATE desc

		--MATCH TO MATCH CONFLICT EXCEP HIST
		UPDATE H
		SET MATCHED='M'
		--SELECT *
		FROM tblPrometricsDailyTaskEight AS H
			INNER JOIN verastem_cm..tblHCOMatchConflictException_HISTORY AS M ON H.CUSTID=M.DataProviderUniqueID
		WHERE H.EntityID IS NULL and CUSTTYPE='HCO' and DATE_ENTERED=CONVERT(date,(getdate()))

		--MATCH TO SOURCE CONFLICT EXCEP HIST
		UPDATE H
		SET MATCHED=CASE WHEN Matched IS NOT NULL THEN 'MS' ELSE 'S' END
		--SELECT *
		FROM tblPrometricsDailyTaskEight AS H
			INNER JOIN verastem_cm..tblHCOSourceConflictException_HISTORY AS M ON H.CUSTID=M.DataProviderUniqueID
		WHERE H.EntityID IS NULL and CUSTTYPE='HCO' and DATE_ENTERED=CONVERT(date,(getdate()))

		--match to outletalternateid
		UPDATE H
		SET MATCHED=ltrim(isnull(matched,'')+'O')
		FROM tblPrometricsDailyTaskEight AS H
			INNER JOIN verastem_cm.cm.tblOutletAlternateId AS M ON H.CUSTID=M.DataProviderUniqueIdentifier
		WHERE H.EntityID IS NULL and CUSTTYPE='HCO' and DATE_ENTERED=CONVERT(date,(getdate()))

		--HAS ENTITY, BUT NO VEEVA
		UPDATE H
		SET NOTES='ENTITY NO VEEVA'
		--SELECT *
		FROM tblPrometricsDailyTaskEight AS H
		WHERE EntityID IS NOT NULL AND VeevaID IS NULL and CUSTTYPE='HCO' and DATE_ENTERED=CONVERT(date,(getdate()))

		--HCOEntityID and a VeevaID, but no Primary_Parent_Vod_C
		UPDATE H
		SET NOTES='ENTITY AND VEEVA NO PRIMARY PARENT'
		--SELECT *
		FROM tblPrometricsDailyTaskEight AS H
		WHERE EntityID IS NOT NULL AND VeevaID IS NOT NULL AND PRIMARY_PARENT IS NULL and CUSTTYPE='HCO' and DATE_ENTERED=CONVERT(date,(getdate()))

		-------------hcp inserts hcpentity is null or veevaid is null or primary parent null
		insert into tblPrometricsDailyTaskEight (CUSTID,CUSTFULLNAME,ENTITYID,VEEVAID,PRIMARY_PARENT,CUSTINSERTDATE,CUSTTYPE,DATE_ENTERED)
		select a.CUSTID, a.CUSTFULLNAME, c.HCPEntityID, e.Veeva_Account_ID_MVN__c,
			e.Primary_Parent_vod__c, a.CUSTINSERTDATE,'HCP',CONVERT(date,getdate()) 
		from verastem..vwPrometricsCustomerMaster a
			inner join verastem..vwPrometricsCustomerAddressMaster b on a.CUSTID = b.CUST_ID
			left join verastem_cm..vwHCPAlternateID c on a.custid = c.DataProviderUniqueIdentifier
			left join verastem..tblStgVeevaAccount e on c.HCPEntityID = e.SHYFT_MDM_EntityID__c
		where CUSTTYPE = 'P' and CUST_COUNTRY in ('US', 'USA')
			and (c.HCPEntityID is null or e.Veeva_Account_ID_MVN__c is null or e.Primary_Parent_vod__c is null)
			and CUSTID not in (select CUSTID from tblPrometricsDailyTaskEight where DATE_ENTERED = convert(date,GETDATE()))
		order by CUSTINSERTDATE desc

		--UPDATE MATCH CONF EXCEP HIST
		UPDATE T
		SET MATCHED ='M'
		--SELECT *
		FROM tblPrometricsDailyTaskEight AS T
			INNER JOIN verastem_cm..tblHCPMatchConflictException_HISTORY AS H ON T.CUSTID=H.DataProviderUniqueID
		WHERE DATE_ENTERED=CONVERT(DATE,GETDATE()) AND CUSTTYPE='HCP' AND ENTITYID IS NULL

		---UPDATE SOURCE CONF EXCEP HIST
		UPDATE T
		SET MATCHED =CASE WHEN MATCHED IS NOT NULL THEN 'MS' ELSE 'M' END
		--SELECT *
		FROM tblPrometricsDailyTaskEight AS T
			INNER JOIN verastem_cm..tblHCPSourceConflictException_HISTORY AS H ON T.CUSTID=H.DataProviderUniqueID
		WHERE DATE_ENTERED=CONVERT(DATE,GETDATE()) AND CUSTTYPE='HCP' AND ENTITYID IS NULL

		--- HCOEntityID but no associated Veeva ID
		UPDATE T
		SET NOTES ='ENTITY NO VEEVA'
		FROM tblPrometricsDailyTaskEight AS T
		WHERE DATE_ENTERED=CONVERT(DATE,GETDATE()) AND CUSTTYPE='HCP' AND ENTITYID IS NOT NULL AND VEEVAID IS NULL

		---- HCPEntityID and a VeevaID, but no Primary_Parent_Vod_C
		UPDATE T
		SET NOTES ='ENTITY AND VEEVA NO PRIMARY PARENT'
		FROM tblPrometricsDailyTaskEight AS T
		WHERE DATE_ENTERED=CONVERT(DATE,GETDATE()) AND CUSTTYPE='HCP' AND ENTITYID IS NOT NULL AND VEEVAID IS NOT NULL AND PRIMARY_PARENT IS NULL

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


