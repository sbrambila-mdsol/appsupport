USE [TPS_DBA]
GO

IF OBJECT_ID('uspGenerateAutoChainJob','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspGenerateAutoChainJob]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspGenerateAutoChainJob] (@NewJobName varchar(255))

--exec uspGenerateAutoChainJob 'Command Center jobs'

AS

DECLARE @ID INT
DECLARE @SQL VARCHAR(8000)
DECLARE @JOBNAME VARCHAR(255)

SET @ID= (SELECT MIN(id) from tblAutomatedJobBuild) 
SET @SQL=''

WHILE @ID <= (SELECT MAX(id) from tblAutomatedJobBuild)
BEGIN
	SET @JOBNAME=(SELECT JOBNAME FROM tblAutomatedJobBuild WHERE id=@ID)
	SET @SQL=@SQL+'
	EXEC TPS_DBA.dbo.uspStartJobWait '''''+@JOBNAME+'''''|'

	SET @ID=@ID+1
END

SET @SQL='EXEC TPS_DBA.DBO.uspCreateJob ''' +@SQL+''''
SET @SQL=LTRIM(RTRIM((LEFT(@SQL,LEN(@SQL)-2))))+RIGHT(@SQL,1)
EXEC(@SQL)

------------rename job
--EXEC msdb.dbo.sp_update_job @job_name=N'Autojob',@new_name=N'Autojob: Command Center jobs'
SET @SQL='EXEC msdb.dbo.sp_update_job @job_name=N''Autojob'',@new_name=N''Autojob: '+@NewJobName+'''
'
--PRINT @SQL
EXEC(@SQL)

------------------get rid of job deletion upon completion
--EXEC msdb.dbo.sp_update_job @job_name=N'Autojob: Command Center jobs', @notify_level_page=2, @delete_level=0
SET @SQL='EXEC msdb.dbo.sp_update_job @job_name=N''Autojob: '+@NewJobName+''',@notify_level_page=2,@delete_level=0
'
--PRINT @SQL
EXEC(@SQL)
GO


