USE [VERASTEM]
GO


IF OBJECT_ID('uspProcessDCRCredential','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspProcessDCRCredential]
GO

/****** Object:  StoredProcedure [dbo].[uspProcessDCRCredential]    Script Date: 12/5/2019 10:38:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[uspProcessDCRCredential]
/*******************************************************************************************
Purpose: To process Credential DCR's		
Inputs:	Veeva	
Author:	
Created:
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspProcessDCRCredential
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM 
					
					---- Staging Tables:
						SELECT * FROM VERASTEM.DBO.tblstgVeevaDataChangeRequest
						SELECT * FROM VERASTEM.DBO.tblstgVeevaDataChangeRequestLine
						SELECT * FROM VERASTEM.DBO.tblstgVeevaCredentialDCR
					


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
SET @DATE=CONVERT(VARCHAR,GETDATE(),101)
--PRINT @DATE

--temp table of dcr requests
SELECT f.id as DCRLineID,d.id as DCRID,d.Notes_vod__c,data_change_request_vod__c,
Field_Api_Name_vod__c,Field_name_vod__c,new_value_vod__c,old_value_vod__c,f.resolution_note_vod__c,
f.result_vod__c,d.account_vod__c,d.status_vod__c,f.lastmodifieddate,f.createddate--select *
into #dcr--select *
FROM [VERASTEM_IM].[dbo].[tbldfVeevaDataChangeRequestLine] as f
	inner join [VERASTEM_IM].[dbo].tbldfVeevaDataChangeRequest as d on f.data_change_request_vod__c=d.id
order by F.ID,f.Field_Api_Name_vod__c

--submitted Credential records
SELECT * 
INTO #Credential
FROM #dcr 
WHERE status_vod__c ='Submitted_vod' and field_api_name_vod__c='Credentials_vod__c'
ORDER BY lastmodifieddate desc

--uniq dcr
select f.Id
INTO #UNIQ
from #dcr as p
	inner join [VERASTEM_IM].[dbo].[tbldfVeevaDataChangeRequest] as f on p.DCRID=f.id
WHERE p.status_vod__c ='Submitted_vod'
GROUP BY f.Id
HAVING COUNT(*) = 1

--multiple dcr
select f.Id
INTO #MANY
from #dcr as p
	inner join [VERASTEM_IM].[dbo].[tbldfVeevaDataChangeRequest] as f on p.DCRID=f.id
where p.status_vod__c ='Submitted_vod'
GROUP BY f.Id
HAVING COUNT(*) > 1

-------check if done already
--done already and can close ;update notes_vod__c,resolution_note_vod__c,result_vod__c, status_vod__c in dcr

--add in case when notes_vod__c is null then 'DCR Received' else notes_vod__c end as Notes_vod__c
--dcr
--CHANGE_APPLIED--
--TRUNCATE TABLE VERASTEM.DBO.tblstgVeevaDataChangeRequest
INSERT INTO VERASTEM.DBO.tblstgVeevaDataChangeRequest
SELECT dcr.Id,'Updated Already' as Notes_vod__c,'PT ' + @DATE + ' Confirmed Credential has already been updated' as 
resolution_note_vod__c,'CHANGE_APPLIED' as result_vod__c,'Completed' as Status_vod__c,0 as Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #Credential AS C ON A.Id=C.ACCOUNT_VOD__C
	inner join [VERASTEM_IM].[dbo].tbldfVeevaDataChangeRequest as dcr on C.DCRID=dcr.Id
WHERE NEW_VALUE_VOD__C=Credentials_vod__c 
AND dcr.Id IN (SELECT Id FROM #UNIQ) AND dcr.resolution_note_vod__c IS NULL

--dcr line update resolution_note_vod__c and Result_vod__c in cdrl
--truncate table VERASTEM.DBO.tblstgVeevaDataChangeRequestLine
insert INTO VERASTEM.DBO.tblstgVeevaDataChangeRequestLine
SELECT RL.Id,'PT '+ @DATE +' Updates to Credential already completed per request' 
as resolution_note_vod__c,'CHANGE_APPLIED' as Result_vod__c,0 as Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #Credential AS C ON A.Id=C.ACCOUNT_VOD__C
	inner join [VERASTEM_IM].[dbo].tbldfVeevaDataChangeRequest as dcr on C.DCRID=dcr.Id
	inner join [VERASTEM_IM].[dbo].[tbldfVeevaDataChangeRequestLine] as RL on C.DCRLineID=RL.Id
WHERE C.NEW_VALUE_VOD__C=Credentials_vod__c AND rl.resolution_note_vod__c IS NULL

--CAN CHANGE; update account
truncate table VERASTEM.DBO.tblstgVeevaCredentialDCR
insert into VERASTEM.DBO.tblstgVeevaCredentialDCR
SELECT A.Id,NEW_VALUE_VOD__C as Credentials_vod__c,0 as Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #Credential AS C ON A.Id=C.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Credentials_vod__c))
AND NEW_VALUE_VOD__C IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount)
order by a.id

--CHANGE_Modified--
--update dcr update notes_vod__c,resolution_note_vod__c,result_vod__c, status_vod__c in dcr
INSERT INTO VERASTEM.DBO.tblstgVeevaDataChangeRequest
SELECT C.DCRID as id,'Now associated with '+a.name as notes_vod__c,'PT '+ @DATE
 +' Approved per guidance from commercial operations' as resolution_note_vod__c,
'CHANGE_MODIFIED' as result_vod__c, 'Completed' as status_vod__c,0 as Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A--select * from #Credential
	INNER JOIN #Credential AS C ON A.Id=C.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Credentials_vod__c))
AND NEW_VALUE_VOD__C IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount)
AND C.DCRID IN (SELECT Id FROM #UNIQ) AND resolution_note_vod__c IS NULL

--update dcrline update resolution_note_vod__c and Result_vod__c
INSERT INTO VERASTEM.DBO.tblstgVeevaDataChangeRequestLine
SELECT C.DCRLineID AS id,'PT '+ @DATE +' Approved per guidance from commercial operations' AS resolution_note_vod__c, 
'CHANGE_MODIFIED' AS Result_vod__c,0 AS Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A--select * from #Credential
	INNER JOIN #Credential AS C ON A.Id=C.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Credentials_vod__c))
AND NEW_VALUE_VOD__C IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount) AND resolution_note_vod__c IS NULL

--CHANGE_DENIED--
--BAD records
--UPDATE DCRLINE
INSERT INTO VERASTEM.DBO.tblstgVeevaDataChangeRequestLine
SELECT C.DCRLineID AS id,'PT'+ @DATE +' Invalid Account '+New_Value_vod__c AS 
resolution_note_vod__c, 'CHANGE_DENIED' AS Result_vod__c,0 AS Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #Credential AS C ON A.Id=C.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Credentials_vod__c))
AND NEW_VALUE_VOD__C NOT IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount) AND resolution_note_vod__c IS NULL


INSERT INTO VERASTEM.DBO.tblstgVeevaDataChangeRequest
SELECT C.DCRID as id,a.name +' does not exist' as notes_vod__c,'PT'+ @DATE +
' Invalid Account '+New_Value_vod__c as resolution_note_vod__c,'CHANGE_DENIED' 
as result_vod__c, 'Completed' as status_vod__c,0 as Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #Credential AS C ON A.Id=C.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Credentials_vod__c))
AND NEW_VALUE_VOD__C NOT IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount)
AND C.DCRID IN (SELECT Id FROM #UNIQ) AND resolution_note_vod__c IS NULL
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


