  use VERASTEM
  go

if not exists (SELECT * FROM agd.tblMdScenarioType WHERE ScenarioTypeDescription='Update Veeva Specialty DCR')
insert into agd.tblMdScenarioType (ScenarioType,ScenarioTypeDescription)
values ('Update Veeva Specialty DCR','Update Veeva Specialty DCR')


if not exists (SELECT * FROM agd.[tblMdDataFeed] WHERE DataFeedDescription='Update Veeva Specialty DCR')
insert into [VERASTEM].[AGD].[tblMdDataFeed](TPSScenarioTypeId,IsZipFile,DataFeedLocation,DataFeedName,DataFeedDescription,LoadOrder,ImportTableName,Active,TaskType,IgnoreFileNotFound)
select TPSScenarioTypeId,0,'SELECT * FROM vwOutbound_Veeva_SpecialtyDCRUpdate',ScenarioType,ScenarioType,10,'Account',0,'SalesforceBulkUpdate',1
from agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Update Veeva Specialty DCR'