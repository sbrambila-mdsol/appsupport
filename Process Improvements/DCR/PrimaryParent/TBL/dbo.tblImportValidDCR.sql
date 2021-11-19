USE <CUSTOMER> --VERASTEM
GO

--Insert ScenarioType Table
  if not exists (SELECT * FROM agd.tblMdScenarioType WHERE ScenarioTypeDescription='Import Valid DCR Request')
  insert into [AGD].[tblMdScenarioType] (ScenarioType,ScenarioTypeDescription)
  values ('Import Valid DCR Request', 'Import Valid DCR Request')

  if not exists (SELECT * FROM agd.tblMdScenarioType WHERE ScenarioTypeDescription='Import Valid DCR Request Line')
  insert into [AGD].[tblMdScenarioType] (ScenarioType,ScenarioTypeDescription)
  values ('Import Valid DCR Request Line', 'Import Valid DCR Request Line')

  if not exists (SELECT * FROM agd.tblMdScenarioType WHERE ScenarioTypeDescription='Import Valid DCR Account Primary')
  insert into [AGD].[tblMdScenarioType] (ScenarioType,ScenarioTypeDescription)
  values ('Import Valid DCR Account Primary', 'Import Valid DCR Account Primary')

--Insert DataFeed Table


if not exists (SELECT * FROM agd.[tblMdDataFeed] WHERE DataFeedDescription='Import Valid DCR Request')
INSERT INTO [AGD].[tblMdDataFeed] (TPSScenarioTypeId,DataFeedLocation,DataFeedName,DataFeedDescription,LoadOrder,ImportTableName,StartLine,Active,AppendToTable,WorkSheets,TaskType,IgnoreFileNotFound)
select TPSScenarioTypeId,'\\PRD<ABBR>10DB1\Development\DCR\DCRValidRecords.xlsx',ScenarioType,ScenarioType,'200','dbo.tblstgVeevaDataChangeRequestValid','1','0','0','0','ExcelImport','0'
from agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Import Valid DCR Request'

if not exists (SELECT * FROM agd.[tblMdDataFeed] WHERE DataFeedDescription='Import Valid DCR Request Line')
INSERT INTO [AGD].[tblMdDataFeed] (TPSScenarioTypeId,DataFeedLocation,DataFeedName,DataFeedDescription,LoadOrder,ImportTableName,StartLine,Active,AppendToTable,WorkSheets,TaskType,IgnoreFileNotFound)
select TPSScenarioTypeId,'\\PRD<ABBR>10DB1\Development\DCR\DCRValidRecords.xlsx',ScenarioType,ScenarioType,'201','dbo.tblstgVeevaDataChangeRequestLineValid','1','0','0','1','ExcelImport','0'
from agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Import Valid DCR Request Line'

if not exists (SELECT * FROM agd.[tblMdDataFeed] WHERE DataFeedDescription='Import Valid DCR Account Primary')
INSERT INTO [AGD].[tblMdDataFeed] (TPSScenarioTypeId,DataFeedLocation,DataFeedName,DataFeedDescription,LoadOrder,ImportTableName,StartLine,Active,AppendToTable,WorkSheets,TaskType,IgnoreFileNotFound)
select TPSScenarioTypeId,'\\PRD<ABBR>10DB1\Development\DCR\DCRValidRecords.xlsx',ScenarioType,ScenarioType,'202','dbo.tblstgVeevaAccountDCRValid','1','0','0','2','ExcelImport','0'
from agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Import Valid DCR Account Primary'

--Insert DataRun Table

if not exists (SELECT * FROM agd.[tblMdDataRun] WHERE ProcessDescription ='Import Valid DCR Request')
insert into [AGD].[tblMdDataRun] (ProcessName ,ProcessDescription ,ExecProcess,ExecOrder ,TPSExecProcessTypeID,Active ,TPSScenarioTypeID ,ContinueOnFail)
select ScenarioType,ScenarioType, 'AGD.uspExecuteTaskManager 1','10','2', '0',TPSScenarioTypeId,'0'
from agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Import Valid DCR Request'

if not exists (SELECT * FROM agd.[tblMdDataRun] WHERE ProcessDescription ='Import Valid DCR Request Line')
insert into [AGD].[tblMdDataRun] (ProcessName ,ProcessDescription ,ExecProcess,ExecOrder,TPSExecProcessTypeID,Active ,TPSScenarioTypeID ,ContinueOnFail)
select ScenarioType,ScenarioType, 'AGD.uspExecuteTaskManager 1','20','2', '0',TPSScenarioTypeId,'0'
from agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Import Valid DCR Request Line'


if not exists (SELECT * FROM agd.[tblMdDataRun] WHERE ProcessDescription ='Import Valid DCR Account Primary')
insert into [AGD].[tblMdDataRun] (ProcessName ,ProcessDescription ,ExecProcess,ExecOrder ,TPSExecProcessTypeID,Active ,TPSScenarioTypeID ,ContinueOnFail)
select ScenarioType,ScenarioType, 'AGD.uspExecuteTaskManager 1','30','2', '0',TPSScenarioTypeId,'0'
from agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Import Valid DCR Account Primary'


