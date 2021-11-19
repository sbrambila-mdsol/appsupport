--all jobs
SELECT *
FROM TPS_DBA..vwJobChainScenarioRelationship
WHERE L1JobName = 'CHAIN CM: Command Center HCP Add'
ORDER BY L2ExecOrder
,        L3ExecOrder
,        L4ExecOrder
,L5ExecOrder

select o.name,j.*
from msdb.dbo.sysjobhistory as j
	inner join msdb.dbo.sysjobs as o on j.job_id=o.job_id
where message like '%fail%' and run_date ='20181120'
order by run_date desc,instance_id

SELECT *
FROM TPS_DBA.DBO.TBLTASKLOG
WHERE CONVERT(DATETIME,STARTTIME) >='11/21/18'

--THIS ONE
SELECT *
FROM TPS_DBA.DBO.TBLTASKQUEUE
WHERE CONVERT(DATETIME,STARTTIME) >='11/21/18' AND ERRORMESSAGE IS NOT NULL

EXEC dbo.uspJobRunDataProcessingJob @JobName='CHAIN CM: Command Center HCP Add', @StartAtStep=20