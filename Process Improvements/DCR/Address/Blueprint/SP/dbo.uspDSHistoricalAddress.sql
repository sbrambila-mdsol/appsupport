USE [BLUEPRINT]
GO

/****** Object:  StoredProcedure [dbo].[uspTemplate]    Script Date: 6/15/2020 9:14:38 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('uspDSHistoricalAddress','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspDSHistoricalAddress]
GO


CREATE PROCEDURE [dbo].[uspDSHistoricalAddress]
/*******************************************************************************************
Purpose:	
Inputs:		
Author:		
Created:	
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspDSHistoricalAddress
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM BLUEPRINT_IM.dbo.tbldf_VCRM_Account
						SELECT * FROM BLUEPRINT_IM.dbo.tbldf_VCRM_Address
					
					---- Staging Tables:
						SELECT * FROM 

					---- Reporting Tables:
						SELECT * FROM blueprint.dbo.DSHistoryAddressItems
						
						--To do
						SELECT * from blueprint.dbo.DSHistoryAddressItems WHERE DateCompleted IS NULL and Notes IS NULL
						



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
		--IDs insert has address with no primary
		insert into DSHistoryAddressItems (TaskNo,VeevaID,RecordType,DateAdded,DescriptionType)
		select distinct '213',a.Id,a.RecordTypeId,GETDATE(),'Has Address With No Primary'
		from BLUEPRINT_IM.dbo.tbldf_VCRM_Account a 
			join BLUEPRINT_IM.dbo.tbldf_VCRM_Address b on a.Id = b.Account_vod__c
		where a.id not in (select VeevaID from DSHistoryAddressItems) and a.ID in (select ID from BLUEPRINT_IM.dbo.tbldf_VCRM_Account
		except
		select a.ID from BLUEPRINT_IM.dbo.tbldf_VCRM_Account a
		join BLUEPRINT_IM.dbo.tbldf_VCRM_Address b
		on a.ID = b.Account_vod__c
		where b.Primary_vod__c = 'true')
		and a.RecordTypeId in ('0120b000000uaSHAAY','0120b000000uaSIAAY')
		order by a.RecordTypeId desc

		--IDs insert no address
		insert into DSHistoryAddressItems (TaskNo,VeevaID,RecordType,DateAdded,DescriptionType)
		select distinct '213',a.Id,a.RecordTypeId,GETDATE(),'No Address' 
		from BLUEPRINT_IM.dbo.tbldf_VCRM_Account a 
			left join BLUEPRINT_IM.dbo.tbldf_VCRM_Address b on a.Id = b.Account_vod__c
		where a.Id not in (select VeevaID_vod__c from DSHistoryAddressItems) and a.ID in (select ID from BLUEPRINT_IM.dbo.tbldf_VCRM_Account
		except
		select a.ID from BLUEPRINT_IM.dbo.tbldf_VCRM_Account a
		join BLUEPRINT_IM.dbo.tbldf_VCRM_Address b
		on a.ID = b.Account_vod__c
		where b.Primary_vod__c = 'true')
		and a.RecordTypeId in ('0120b000000uaSHAAY','0120b000000uaSIAAY')
		and b.Id is null
		order by a.RecordTypeId

		--update processed records
		update B
		set VeevaAddressID=A.id,DateCompleted=a.LastModifiedDate,CompletedBy=a.LastModifiedById,Address1=a.Name,Address2=a.Address_line_2_vod__c,City=a.City_vod__c,State=a.State_vod__c,Zip=a.Zip_vod__c
		from blueprint.dbo.DSHistoryAddressItems as b
			inner join BLUEPRINT_IM.dbo.tbldf_VCRM_Address as a on b.VeevaID=a.Account_vod__c
		where a.Primary_vod__c='true' and B.DateCompleted is null AND B.Notes is null
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


