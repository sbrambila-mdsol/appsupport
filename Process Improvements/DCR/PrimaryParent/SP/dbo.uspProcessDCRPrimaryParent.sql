USE [<Customer>]
GO

IF OBJECT_ID('uspProcessDCRPrimaryParent','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspProcessDCRPrimaryParent]
GO

/****** Object:  StoredProcedure [dbo].[uspProcessDCRPrimaryParent]    Script Date: 10/31/2019 5:17:03 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspProcessDCRPrimaryParent]
/*******************************************************************************************
Purpose: To process Primary Parent DCR's		
Inputs:	Veeva	
Author:	Todd Forman	
Created: 10/16/2019	
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspProcessDCRPrimaryParent
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM 
					
					---- Staging Tables:
						SELECT * FROM <Customer>.DBO.tblstgVeevaDataChangeRequest
						SELECT * FROM <Customer>.DBO.tblstgVeevaDataChangeRequestLine
						SELECT * FROM <Customer>.DBO.tblstgVeevaAccountDCR

					---- Reporting Tables:
						SELECT * FROM 
						



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
		--set date
DECLARE @DATE VARCHAR(12)
SET @DATE=CONVERT(VARCHAR,GETDATE(),101)--'10/11/2019'
--PRINT @DATE

--temp table of dcr requests
SELECT f.id as DCRLineID,d.id as DCRID,d.Notes_vod__c,data_change_request_vod__c,Field_Api_Name_vod__c,Field_name_vod__c,new_value_vod__c,old_value_vod__c,f.resolution_note_vod__c,f.result_vod__c,d.account_vod__c,d.status_vod__c,f.lastmodifieddate,f.createddate--select *
into #dcr--select *
FROM [<Customer>_IM].[dbo].[tbldfVeevaDataChangeRequestLine] as f
	inner join [<Customer>_IM].[dbo].tbldfVeevaDataChangeRequest as d on f.data_change_request_vod__c=d.id
order by F.ID,f.Field_Api_Name_vod__c

--submitted primary parent records
SELECT * 
INTO #PRIMPARENT
FROM #dcr 
WHERE status_vod__c ='Submitted_vod' and field_api_name_vod__c='Primary_Parent_vod__c'
ORDER BY lastmodifieddate desc

--uniq dcr
select f.Id
INTO #UNIQ
from #dcr as p
	inner join [<Customer>_IM].[dbo].[tbldfVeevaDataChangeRequest] as f on p.DCRID=f.id
WHERE p.status_vod__c ='Submitted_vod'
GROUP BY f.Id
HAVING COUNT(*) = 1

--multiple dcr
select f.Id
INTO #MANY
from #dcr as p
	inner join [<Customer>_IM].[dbo].[tbldfVeevaDataChangeRequest] as f on p.DCRID=f.id
where p.status_vod__c ='Submitted_vod'
GROUP BY f.Id
HAVING COUNT(*) > 1

-------check if done already
--done already and can close ;update notes_vod__c,resolution_note_vod__c,result_vod__c, status_vod__c in dcr

--add in case when notes_vod__c is null then 'DCR Received' else notes_vod__c end as Notes_vod__c
--dcr
TRUNCATE TABLE <Customer>.DBO.tblstgVeevaDataChangeRequest
INSERT INTO <Customer>.DBO.tblstgVeevaDataChangeRequest
SELECT dcr.Id,'Updated Already' as Notes_vod__c,'PT ' + @DATE + ' Confirmed primary parent has already been updated' as resolution_note_vod__c,'CHANGE_ALREADYAPPLIED' as result_vod__c,'Completed' as Status_vod__c,0 as Valid
FROM <Customer>_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #PRIMPARENT AS P ON A.Id=P.ACCOUNT_VOD__C
	inner join [<Customer>_IM].[dbo].tbldfVeevaDataChangeRequest as dcr on P.DCRID=dcr.Id
WHERE NEW_VALUE_VOD__C=PRIMARY_PARENT_VOD__C 
AND dcr.Id IN (SELECT Id FROM #UNIQ) AND dcr.resolution_note_vod__c IS NULL

--dcr line update resolution_note_vod__c and Result_vod__c in cdrl
truncate table <Customer>.DBO.tblstgVeevaDataChangeRequestLine
insert INTO <Customer>.DBO.tblstgVeevaDataChangeRequestLine
SELECT RL.Id,'PT '+ @DATE +' Updates to primary parent already completed per request' as resolution_note_vod__c,'CHANGE_ALREADYAPPLIED' as Result_vod__c,0 as Valid
FROM <Customer>_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #PRIMPARENT AS P ON A.Id=P.ACCOUNT_VOD__C
	inner join [<Customer>_IM].[dbo].tbldfVeevaDataChangeRequest as dcr on P.DCRID=dcr.Id
	inner join [<Customer>_IM].[dbo].[tbldfVeevaDataChangeRequestLine] as RL on P.DCRLineID=RL.Id
WHERE p.NEW_VALUE_VOD__C=PRIMARY_PARENT_VOD__C AND rl.resolution_note_vod__c IS NULL

--CAN CHANGE; update account
truncate table <Customer>.DBO.tblstgVeevaAccountDCR
insert into <Customer>.DBO.tblstgVeevaAccountDCR
SELECT A.Id,NEW_VALUE_VOD__C as PRIMARY_PARENT_VOD__C,0 as Valid
FROM <Customer>_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #PRIMPARENT AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>ISNULL(LTRIM(RTRIM(PRIMARY_PARENT_VOD__C)),'~')
AND NEW_VALUE_VOD__C IN (SELECT Id FROM <Customer>_IM.DBO.tbldfVeevaAccount)
order by a.id

--update dcr update notes_vod__c,resolution_note_vod__c,result_vod__c, status_vod__c in dcr
INSERT INTO <Customer>.DBO.tblstgVeevaDataChangeRequest
SELECT P.DCRID as id,'Now associated with '+a.name as notes_vod__c,'PT '+ @DATE +' Approved per guidance from commercial operations' as resolution_note_vod__c,'CHANGE_ACCEPTED' as result_vod__c, 'Completed' as status_vod__c,0 as Valid
FROM <Customer>_IM.DBO.tbldfVeevaAccount AS A--select * from #primparent
	INNER JOIN #PRIMPARENT AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>ISNULL(LTRIM(RTRIM(PRIMARY_PARENT_VOD__C)),'~')
AND NEW_VALUE_VOD__C IN (SELECT Id FROM <Customer>_IM.DBO.tbldfVeevaAccount)
AND P.DCRID IN (SELECT Id FROM #UNIQ) AND resolution_note_vod__c IS NULL

--update dcrline update resolution_note_vod__c and Result_vod__c
INSERT INTO <Customer>.DBO.tblstgVeevaDataChangeRequestLine
SELECT P.DCRLineID AS id,'PT '+ @DATE +' Approved per guidance from commercial operations' AS resolution_note_vod__c, 'CHANGE_ACCEPTED' AS Result_vod__c,0 AS Valid
FROM <Customer>_IM.DBO.tbldfVeevaAccount AS A--select * from #primparent
	INNER JOIN #PRIMPARENT AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>ISNULL(LTRIM(RTRIM(PRIMARY_PARENT_VOD__C)),'~')
AND NEW_VALUE_VOD__C IN (SELECT Id FROM <Customer>_IM.DBO.tbldfVeevaAccount) AND resolution_note_vod__c IS NULL

--BAD records
--UPDATE DCRLINE
INSERT INTO <Customer>.DBO.tblstgVeevaDataChangeRequestLine
SELECT P.DCRLineID AS id,'PT'+ @DATE +' Invalid Account '+New_Value_vod__c AS resolution_note_vod__c, 'CHANGE_DENIED' AS Result_vod__c,0 AS Valid
FROM <Customer>_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #PRIMPARENT AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>ISNULL(LTRIM(RTRIM(PRIMARY_PARENT_VOD__C)),'~')
AND NEW_VALUE_VOD__C NOT IN (SELECT Id FROM <Customer>_IM.DBO.tbldfVeevaAccount) AND resolution_note_vod__c IS NULL


INSERT INTO <Customer>.DBO.tblstgVeevaDataChangeRequest
SELECT P.DCRID as id,a.name +' does not exist' as notes_vod__c,'PT'+ @DATE +' Invalid Account '+New_Value_vod__c as resolution_note_vod__c,'CHANGE_DENIED' as result_vod__c, 'Completed' as status_vod__c,0 as Valid
FROM <Customer>_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #PRIMPARENT AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>ISNULL(LTRIM(RTRIM(PRIMARY_PARENT_VOD__C)),'~')
AND NEW_VALUE_VOD__C NOT IN (SELECT Id FROM <Customer>_IM.DBO.tbldfVeevaAccount)
AND P.DCRID IN (SELECT Id FROM #UNIQ) AND resolution_note_vod__c IS NULL
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


