  use VERASTEM
  go

if not exists (SELECT * FROM agd.tblMdScenarioType WHERE ScenarioTypeDescription='Update Veeva DCR Credential')
insert into agd.tblMdScenarioType (ScenarioType,ScenarioTypeDescription)
values ('Update Veeva DCR Credential','Update Veeva DCR Credential')

if not exists (SELECT * FROM agd.[tblMdDataFeed] WHERE DataFeedDescription='Update Veeva DCR Credential')
insert into [VERASTEM].[AGD].[tblMdDataFeed](TPSScenarioTypeId,IsZipFile,DataFeedLocation,DataFeedName,
DataFeedDescription,LoadOrder,ImportTableName,Active,TaskType,IgnoreFileNotFound)
select TPSScenarioTypeId,0,'SELECT * FROM vwOutbound_Veeva_DCRCredentialUpdate',ScenarioType,
ScenarioType,10,'Credential',0,'SalesforceBulkUpdate',1
from agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Update Veeva DCR Credential'

