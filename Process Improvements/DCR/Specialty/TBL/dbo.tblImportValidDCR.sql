
--Import Valid Specialty DCR
--Scenariotype

  if not exists (SELECT * FROM [VERASTEM].agd.tblMdScenarioType WHERE ScenarioTypeDescription='Import Valid DCR Account Specialty')
  insert into [VERASTEM].[AGD].[tblMdScenarioType] (ScenarioType,ScenarioTypeDescription)
  values ('Import Valid DCR Account Specialty', 'Import Valid DCR Account Specialty')

  --Datafeed table

  if not exists (SELECT * FROM [VERASTEM].agd.[tblMdDataFeed] WHERE DataFeedDescription='Import Valid DCR Account Specialty')
INSERT INTO [VERASTEM].[AGD].[tblMdDataFeed] (TPSScenarioTypeId,DataFeedLocation,DataFeedName,DataFeedDescription,LoadOrder,ImportTableName,StartLine,Active,AppendToTable,WorkSheets,TaskType,IgnoreFileNotFound)
select TPSScenarioTypeId,'\\PRDVER10DB1\Development\DCR\DCRValidRecords.xlsx',ScenarioType,ScenarioType,'203','dbo.tblstgVeevaSpecialtyDCRValid','1','0','0','3','ExcelImport','0'
from [VERASTEM].agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Import Valid DCR Account Specialty'

--DataRun table

if not exists (SELECT * FROM [VERASTEM].agd.[tblMdDataRun] WHERE ProcessDescription ='Import Valid DCR Account Specialty')
insert into [VERASTEM].[AGD].[tblMdDataRun] (ProcessName ,ProcessDescription ,ExecProcess,ExecOrder ,TPSExecProcessTypeID,Active ,TPSScenarioTypeID ,ContinueOnFail)
select ScenarioType,ScenarioType, 'AGD.uspExecuteTaskManager 1','40','2', '0',TPSScenarioTypeId,'0'
from [VERASTEM].agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Import Valid DCR Account Specialty'

