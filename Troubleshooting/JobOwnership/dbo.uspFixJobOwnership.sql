USE [TPS_DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspFixJobOwnership]    Script Date: 10/10/2018 9:45:32 AM ******/
IF OBJECT_ID('uspFixJobOwnership','P') IS NOT NULL DROP PROCEDURE [dbo].[uspFixJobOwnership]
GO

/****** Object:  StoredProcedure [dbo].[uspFixJobOwnership]    Script Date: 10/10/2018 9:45:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET NOCOUNT ON
GO


CREATE PROCEDURE [dbo].[uspFixJobOwnership]

AS
declare @svcaccname varchar(100) = (SELECT name FROM msdb.dbo.syslogins where name like '%svc' and name not like '%web%' and name not like '%ami%' and name not like '%tab%')

--check before; Create table of issues
SELECT SUSER_SNAME([jobs].[owner_sid]) AS OWNER,JOB_ID,NAME,ENABLED
INTO #JobOwnerIssues
FROM [msdb].[dbo].[sysjobs] AS [jobs] WITh(NOLOCK) 
WHERE SUSER_SNAME([jobs].[owner_sid]) <> 'SA' AND SUSER_SNAME([jobs].[owner_sid]) <> @svcaccname
ORDER BY SUSER_SNAME([jobs].[owner_sid])

--SELECT * FROM #JobOwnerIssues

DECLARE @JOB VARCHAR(255)

  DECLARE JobName_CURSOR CURSOR FOR 
	  SELECT NAME
	  FROM #JobOwnerIssues
	  ORDER BY NAME

	  OPEN JobName_CURSOR
	  
	  FETCH NEXT FROM JobName_CURSOR
	  INTO @JOB

	  WHILE @@FETCH_STATUS = 0 
	  BEGIN
		   EXEC msdb.dbo.sp_update_job  
			@job_name = @JOB,
			@owner_login_name = @svcaccname

		FETCH NEXT FROM JobName_CURSOR INTO @JOB
	  END	

	  CLOSE JobName_CURSOR
	  DEALLOCATE JobName_CURSOR


--check after
--SELECT SUSER_SNAME([jobs].[owner_sid]) AS OWNER,JOB_ID,NAME,ENABLED
--FROM [msdb].[dbo].[sysjobs] AS [jobs] WITh(NOLOCK) 
--ORDER BY SUSER_SNAME([jobs].[owner_sid])
GO


