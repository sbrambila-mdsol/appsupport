USE [TPS_DBA]
GO

IF OBJECT_ID('uspAddressMismatches','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspAddressMismatches]
GO

/****** Object:  StoredProcedure [dbo].[uspAddressMismatches]    Script Date: 6/29/2020 11:44:31 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspAddressMismatches]

AS

SET NOCOUNT ON

--EXEC TPS_DBA. dbo.uspAddressMismatches

SELECT r.name as AcctType,M.LungTier,M.PMA_Tier,M.GISTTier,SHYFT_MDM_BlueprintID_c__c as ShyftMDMID,a.*
INTO #accts
FROM [BLUEPRINT_IM].[dbo].[tbldf_VCRM_Account] as a
	INNER JOIN [BLUEPRINT_IM].dbo.tbldf_VCRM_RecordType as r on a.RecordTypeId=r.Id 
	INNER JOIN [BLUEPRINT_CM].[CM].[tblHCPMaster] AS M ON a.SHYFT_MDM_BlueprintID_c__c=M.TPSEntityId
WHERE a.BPM_PAL_Target__c='True'
	and r.SobjectType='Account'
	and r.IsPersonType='true'
	and r.IsActive='true'

SELECT distinct A.LungTier,A.PMA_Tier,A.GISTTier,a.ShyftMDMID,A.Id,A.Name,
	D.NAME AS ADDRESS1, D.Address_line_2_vod__c,D.City_vod__c,D.State_vod__c,D.Zip_vod__c,
	A.Primary_Parent_vod__c,c.name as PrimName,D2.NAME AS PrimADDRESS1, D2.Address_line_2_vod__c as PrimAddress2,D2.City_vod__c as PrimCity,
	D2.State_vod__c as PrimState,D2.Zip_vod__c as PrimZip,b.TerritoryCode,b2.TerritoryCode as PrimTerr
INTO #ACCTADDRESS--select *
FROM #accts AS A
	INNER JOIN blueprint_im.dbo.tbldf_VCRM_Address AS D ON A.Id=D.Account_vod__c
	INNER JOIN blueprint_im.dbo.tbldf_VCRM_Address AS D2 ON A.Primary_Parent_vod__c=D2.Account_vod__c
	INNER JOIN blueprint_im.dbo.tbldf_VCRM_Account as C on A.Primary_Parent_vod__c=C.id
	INNER JOIN BLUEPRINT_IM.dbo.tbldf_Blueprint_ZipTerr as b on D.Zip_vod__c=b.ZIP and b.FieldForceName='abm'
	INNER JOIN BLUEPRINT_IM.dbo.tbldf_Blueprint_ZipTerr as b2 on D2.Zip_vod__c=b2.ZIP and b2.FieldForceName='abm'
WHERE d.Primary_vod__c = 'true' and D2.Primary_vod__c='true'
ORDER BY A.ID

--select * from #ACCTADDRESS

TRUNCATE TABLE Blueprint.dbo.stgPotentialMisMatches
INSERT INTO Blueprint.dbo.stgPotentialMisMatches
select distinct a.*
from #ACCTADDRESS as a
where isnull(a.Zip_vod__c,'~')<>isnull(PrimZip,'~') and isnull(a.State_vod__c,'~') <> isnull(PrimState,'~')

GO


