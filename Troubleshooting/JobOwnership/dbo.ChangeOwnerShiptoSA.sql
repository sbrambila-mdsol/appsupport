declare @svcaccname varchar(100) = 'sa'

--check before; Create table of issues 
--drop table #JobOwnerIssues
SELECT SUSER_SNAME([jobs].[owner_sid]) AS OWNER,JOB_ID,NAME,ENABLED
INTO #JobOwnerIssues
FROM [msdb].[dbo].[sysjobs] AS [jobs] WITh(NOLOCK) 
WHERE --SUSER_SNAME([jobs].[owner_sid]) <> 'SA' AND 
SUSER_SNAME([jobs].[owner_sid]) LIKE '%SVC' and name not like 'zz%'
ORDER BY name

--select * from #JobOwnerIssues order by name

--SELECT * into dbo.JobOwnerChanges FROM #JobOwnerIssues

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
