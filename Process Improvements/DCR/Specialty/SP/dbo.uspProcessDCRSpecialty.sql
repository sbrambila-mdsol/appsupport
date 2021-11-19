USE [VERASTEM]
GO

IF OBJECT_ID('uspProcessDCRSpecialty','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspProcessDCRSpecialty]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspProcessDCRSpecialty]
/*******************************************************************************************
Purpose: To process Specialty DCR's		
Inputs:	Veeva	
Author:	Rimona Saikia
Created: 11/24/2019	
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspProcessDCRSpecialty
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM 
					
					---- Staging Tables:
						SELECT * FROM VERASTEM.DBO.tblstgVeevaDataChangeRequest
						SELECT * FROM VERASTEM.DBO.tblstgVeevaDataChangeRequestLine
						SELECT * FROM VERASTEM.DBO.tblstgVeevaSpecialtyDCR

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
SET @DATE=CONVERT(VARCHAR,GETDATE(),101)--'11/24/2019'
--PRINT @DATE

--temp table of dcr requests
SELECT f.id as DCRLineID,d.id as DCRID,d.Notes_vod__c,data_change_request_vod__c,Field_Api_Name_vod__c,Field_name_vod__c,new_value_vod__c,old_value_vod__c,f.resolution_note_vod__c,f.result_vod__c,d.account_vod__c,d.status_vod__c,f.lastmodifieddate,f.createddate--select *
into #dcr--select *
FROM [VERASTEM_IM].[dbo].[tbldfVeevaDataChangeRequestLine] as f
	inner join [VERASTEM_IM].[dbo].tbldfVeevaDataChangeRequest as d on f.data_change_request_vod__c=d.id
order by F.ID,f.Field_Api_Name_vod__c

--submitted specialty records
SELECT * 
INTO #SPECIALTY
FROM #dcr 
WHERE status_vod__c ='Submitted_vod' and field_api_name_vod__c='Specialty_1_vod__c'
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


--CAN CHANGE; update account
--truncate table VERASTEM.DBO.tblstgVeevaSpecialtyDCR

insert into VERASTEM.DBO.tblstgVeevaSpecialtyDCR
SELECT A.Id,NEW_VALUE_VOD__C as Specialty_1_vod__c,0 as Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #SPECIALTY AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Specialty_1_vod__c))
AND NEW_VALUE_VOD__C IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount)
order by a.id

--update dcr update notes_vod__c,resolution_note_vod__c,result_vod__c, status_vod__c in dcr
INSERT INTO VERASTEM.DBO.tblstgVeevaDataChangeRequest
SELECT P.DCRID as id,'Now associated with '+a.name as notes_vod__c,'PT '+ @DATE +' Approved per guidance from commercial operations' as resolution_note_vod__c,'CHANGE_APPLIED' as result_vod__c, 'Completed' as status_vod__c,0 as Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A--select * from #primparent
	INNER JOIN #SPECIALTY AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Specialty_1_vod__c))
AND NEW_VALUE_VOD__C IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount)
AND P.DCRID IN (SELECT Id FROM #UNIQ) AND resolution_note_vod__c IS NULL

--update dcrline update resolution_note_vod__c and Result_vod__c
INSERT INTO VERASTEM.DBO.tblstgVeevaDataChangeRequestLine
SELECT P.DCRLineID AS id,'PT '+ @DATE +' Approved per guidance from commercial operations' AS resolution_note_vod__c, 'CHANGE_APPLIED' AS Result_vod__c,0 AS Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A--select * from #primparent
	INNER JOIN #SPECIALTY AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Specialty_1_vod__c))
AND NEW_VALUE_VOD__C IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount) AND resolution_note_vod__c IS NULL

--BAD records
--UPDATE DCRLINE
INSERT INTO VERASTEM.DBO.tblstgVeevaDataChangeRequestLine
SELECT P.DCRLineID AS id,'PT'+ @DATE +' Invalid Account '+New_Value_vod__c AS resolution_note_vod__c, 'CHANGE_DENIED' AS Result_vod__c,0 AS Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #SPECIALTY AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Specialty_1_vod__c))
AND NEW_VALUE_VOD__C NOT IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount) AND resolution_note_vod__c IS NULL


INSERT INTO VERASTEM.DBO.tblstgVeevaDataChangeRequest
SELECT P.DCRID as id,'PT'+a.name +' does not exist' as notes_vod__c, @DATE +' Invalid Account '+New_Value_vod__c as resolution_note_vod__c,'CHANGE_DENIED' as result_vod__c, 'Completed' as status_vod__c,0 as Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #SPECIALTY AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Specialty_1_vod__c))
AND NEW_VALUE_VOD__C NOT IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount)
AND P.DCRID IN (SELECT Id FROM #UNIQ) AND resolution_note_vod__c IS NULL

--Change Modified
--Update DCR update notes_vod__c,resolution_note_vod__c,result_vod__c, status_vod__c in dcr
INSERT INTO VERASTEM.DBO.tblstgVeevaDataChangeRequest
SELECT @DATE + 'Modifying change to keep account' + a.name as notes_vod__c,'PT'+'for DCR' + P.DCRID as id , 'active' as resolution_note_vod__c,'CHANGE_MODIFIED' as result_vod__c, 'Completed' as status_vod__c,0 as Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A--select * from #primparent
	INNER JOIN #SPECIALTY AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Specialty_1_vod__c))
AND NEW_VALUE_VOD__C IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount)
AND P.DCRID IN (SELECT Id FROM #UNIQ) AND resolution_note_vod__c IS NULL

INSERT INTO VERASTEM.DBO.tblstgVeevaDataChangeRequest
SELECT @DATE + 'Modifying change to keep account' + a.name as notes_vod__c,'PT'+'for DCR' + P.DCRID as id , 'active' as resolution_note_vod__c,'CHANGE_MODIFIED' as result_vod__c, 'Completed' as status_vod__c,0 as Valid
FROM VERASTEM_IM.DBO.tbldfVeevaAccount AS A
	INNER JOIN #SPECIALTY AS P ON A.Id=P.ACCOUNT_VOD__C
WHERE LTRIM(RTRIM(NEW_VALUE_VOD__C))<>LTRIM(RTRIM(Specialty_1_vod__c))
AND NEW_VALUE_VOD__C NOT IN (SELECT Id FROM VERASTEM_IM.DBO.tbldfVeevaAccount)
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


