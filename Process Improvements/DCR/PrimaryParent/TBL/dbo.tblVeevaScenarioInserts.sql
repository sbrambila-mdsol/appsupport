USE <Customer>--BLUEPRINT
GO

IF NOT EXISTS (SELECT 1 FROM [AGD].[tblMdScenarioType] WHERE ScenarioTypeDescription='Import Veeva DCR Objects')
INSERT INTO [AGD].[tblMdScenarioType] (ScenarioType,ScenarioTypeDescription)
VALUES ('Import Veeva DCR Objects','Import Veeva DCR Objects')