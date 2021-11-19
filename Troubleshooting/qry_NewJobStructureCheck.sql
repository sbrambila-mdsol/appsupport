--replace <customer> with processing db name
--replace <scenarioid> with tpsscenariotypeid
--Note l2execorder is the startat step for re-runs

use <customer>
go

--all jobs
SELECT *
FROM TPS_DBA..vwJobChainScenarioRelationship
WHERE L1JobName = '_MASTER: DAILY CHAIN'
ORDER BY L2ExecOrder
,        L3ExecOrder
,        L4ExecOrder
,L5ExecOrder

select *
from <customer>.agd.tblmddatarun
where tpsscenariotypeid=<scenarioid>
order by execorder


select *
from <customer>.agd.tblmddatarunlog
order by endtime desc

select *
from <customer>.agd.vwLatestProcessLog
order by 1 desc




