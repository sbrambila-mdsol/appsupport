use msdb
go

SELECT j.Name, jh.Step_name,
	CONVERT(DATETIME, RTRIM(jh.run_date)) + ((jh.run_time/10000 * 3600) + ((jh.run_time%10000)/100*60) +
	(jh.run_time%10000)%100 /*run_time_elapsed_seconds*/) / (23.999999*3600 /* seconds in a day*/)
	AS Start_DateTime,
	CONVERT(DATETIME, RTRIM(jh.run_date)) + ((jh.run_time/10000 * 3600) + ((jh.run_time%10000)/100*60) +
	(jh.run_time%10000)%100) / (86399.9964 /* Start Date Time */)
	+ ((jh.run_duration/10000 * 3600) + ((jh.run_duration%10000)/100*60) + (jh.run_duration%10000)%100
	/*run_duration_elapsed_seconds*/) / (86399.9964 /* seconds in a day*/) AS End_DateTime,
	CONVERT(CHAR(10), CAST(STR(jh.run_date,8, 0) AS dateTIME), 111) RunDate, 
	STUFF(STUFF(RIGHT('000000' + CAST ( jh.run_time AS VARCHAR(6 ) ) ,6),5,0,':'),3,0,':') RunTime, 
	jh.run_duration StepDuration,
	case jh.run_status when 0 then 'failed'
	when 1 then 'Succeded' 
	when 2 then 'Retry' 
	when 3 then 'Cancelled' 
	when 4 then 'In Progress' 
	end as ExecutionStatus, 
	jh.message MessageGenerated
from msdb..sysjobhistory jh
	inner join msdb..sysjobs j on jh.job_id=j.job_id
ORDER BY run_date desc, run_time desc

--select * from sysjobhistory