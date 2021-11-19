use msdb
go

SELECT j.*,s.name
FROM dbo.sysjobs AS S
	INNER JOIN dbo.sysjobschedules  AS J
ON S.job_id = J.job_id
WHERE j.schedule_id in (
SELECT J.SCHEDULE_ID
FROM dbo.sysjobs AS S
	INNER JOIN dbo.sysjobschedules  AS J
ON S.job_id = J.job_id
GROUP BY j.schedule_id
HAVING COUNT(*) >1)
ORDER BY j.schedule_id,s.name

