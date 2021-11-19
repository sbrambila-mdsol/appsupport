  use <customer>--BLUEPRINT
  go

if not exists (SELECT * FROM agd.tblMdScenarioType WHERE ScenarioTypeDescription='Update Veeva DCR Account')
insert into agd.tblMdScenarioType (ScenarioType,ScenarioTypeDescription)
values ('Update Veeva DCR Account','Update Veeva DCR Account')

if not exists (SELECT * FROM agd.tblMdScenarioType WHERE ScenarioTypeDescription='Update Veeva DCR Header')
insert into agd.tblMdScenarioType (ScenarioType,ScenarioTypeDescription)
values ('Update Veeva DCR Header','Update Veeva DCR Header')

if not exists (SELECT * FROM agd.tblMdScenarioType WHERE ScenarioTypeDescription='Update Veeva DCR Line Item')
insert into agd.tblMdScenarioType (ScenarioType,ScenarioTypeDescription)
values ('Update Veeva DCR Line Item','Update Veeva DCR Line Item')

if not exists (SELECT * FROM agd.[tblMdDataFeed] WHERE DataFeedDescription='Update Veeva DCR Account')
insert into [<Customer>].[AGD].[tblMdDataFeed](TPSScenarioTypeId,IsZipFile,DataFeedLocation,DataFeedName,DataFeedDescription,LoadOrder,ImportTableName,Active,TaskType,IgnoreFileNotFound)
select TPSScenarioTypeId,0,'SELECT * FROM vwOutbound_Veeva_DCRAccountUpdate',ScenarioType,ScenarioType,10,'Account',0,'SalesforceBulkUpdate',1
from agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Update Veeva DCR Account'

if not exists (SELECT * FROM agd.[tblMdDataFeed] WHERE DataFeedDescription='Update Veeva DCR Header')
insert into [<Customer>].[AGD].[tblMdDataFeed](TPSScenarioTypeId,IsZipFile,DataFeedLocation,DataFeedName,DataFeedDescription,LoadOrder,ImportTableName,Active,TaskType,IgnoreFileNotFound)
select TPSScenarioTypeId,0,'SELECT * FROM vwOutbound_Veeva_DCRUpdate',ScenarioType,ScenarioType,10,'Data_Change_Request_vod__c',0,'SalesforceBulkUpdate',1
from agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Update Veeva DCR Header'

if not exists (SELECT * FROM agd.[tblMdDataFeed] WHERE DataFeedDescription='Update Veeva DCR Line Item')
insert into [<Customer>].[AGD].[tblMdDataFeed](TPSScenarioTypeId,IsZipFile,DataFeedLocation,DataFeedName,DataFeedDescription,LoadOrder,ImportTableName,Active,TaskType,IgnoreFileNotFound)
select TPSScenarioTypeId,0,'SELECT * FROM vwOutbound_Veeva_DCRLineUpdate',ScenarioType,ScenarioType,10,'Data_Change_Request_Line_vod__c',0,'SalesforceBulkUpdate',1
from agd.tblMdScenarioType 
WHERE ScenarioTypeDescription='Update Veeva DCR Line Item'