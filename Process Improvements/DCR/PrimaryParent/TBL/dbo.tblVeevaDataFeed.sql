USE <customer>--Blueprint
GO

DECLARE @ScenarioTypeID INT=(SELECT TPSScenarioTypeId FROM [AGD].[tblMdScenarioType] WHERE ScenarioTypeDescription='Import Veeva DCR Objects')
--PRINT @ScenarioTypeID

IF NOT EXISTS (SELECT 1 FROM [AGD].[tblMdDataFeed] WHERE ImportTableName='tbldfVeevaDataChangeRequest')
INSERT INTO [AGD].[tblMdDataFeed] (TPSScenarioTypeId,IsZipFile,DataFeedLocation,DataFeedName,DataFeedDescription,LoadOrder,ImportTableName,Active,TaskType,IgnoreFileNotFound,allowClientUpload,DropTable)
VALUES (@ScenarioTypeID,'0','SELECT * FROM Data_Change_Request_vod__c','Import Veeva Data_Change_Request_vod__c','Import Veeva Data_Change_Request_vod__c','200','tbldfVeevaDataChangeRequest','0','SalesforceBulkImport','1','0','1')

IF NOT EXISTS (SELECT 1 FROM [AGD].[tblMdDataFeed] WHERE ImportTableName='tbldfVeevaDataChangeRequestLine')
INSERT INTO [AGD].[tblMdDataFeed] (TPSScenarioTypeId,IsZipFile,DataFeedLocation,DataFeedName,DataFeedDescription,LoadOrder,ImportTableName,Active,TaskType,IgnoreFileNotFound,allowClientUpload,DropTable)
VALUES (@ScenarioTypeID,'0','SELECT * FROM Data_Change_Request_Line_vod__c','Import Veeva Data_Change_Request_Line_vod__c','Import Veeva Data_Change_Request_Line_vod__c','201','tbldfVeevaDataChangeRequestLine','0','SalesforceBulkImport','1','0','1')

IF NOT EXISTS (SELECT 1 FROM [AGD].[tblMdDataFeed] WHERE ImportTableName='tbldfVeevaBPMWebLeadSuggestion')
INSERT INTO [AGD].[tblMdDataFeed] (TPSScenarioTypeId,IsZipFile,DataFeedLocation,DataFeedName,DataFeedDescription,LoadOrder,ImportTableName,Active,TaskType,IgnoreFileNotFound,allowClientUpload,DropTable)
VALUES (@ScenarioTypeID,'0','SELECT * FROM BPM_Web_Lead_Suggestion__c','Import Veeva BPM_Web_Lead_Suggestion__c','Import Veeva BPM_Web_Lead_Suggestion__c','202','tbldfVeevaBPMWebLeadSuggestion','0','SalesforceBulkImport','1','0','1')





