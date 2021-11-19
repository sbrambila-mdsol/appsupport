update p
set isprocessing=0
FROM TPS_DBA.dbo.tblMdJobDataProcessing   as p
where IsProcessing=1

update p
set isprocessing=0
FROM TPS_DBA.dbo.tblMdJobScenarioStep as p 
where IsProcessing=1