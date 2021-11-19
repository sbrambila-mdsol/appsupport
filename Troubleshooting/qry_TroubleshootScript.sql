--replace <customer> with db name
--replace <Scenarioid> with the tpsscenariotypeid


USE <Customer>--INSMED
GO

SELECT *
FROM [AGD].[tblQAResults] 
WHERE isfailure=1 AND InsertDate >= DATEADD(DD,-1,getdate())
ORDER BY InsertDate DESC


DECLARE @ScenarioID INT

SET @ScenarioID=<Scenarioid>--38

SELECT *
FROM AGD.TBLMDDATARUN
WHERE TPSScenarioTypeID=@ScenarioID
ORDER BY EXECORDER

SELECT *
FROM AGD.tblMdDataFeed
WHERE TPSScenarioTypeID=@ScenarioID
ORDER BY LoadOrder

SELECT *
FROM AGD.tblMdDataFeedDownload
WHERE TPSDataFeedID IN (SELECT TPSDataFeedID
FROM AGD.tblMdDataFeed
WHERE TPSScenarioTypeID=@ScenarioID)

SELECT *
FROM AGD.tblMdSetting
WHERE SETTINGNAME IN ('DatafeedLOCATION','ENVIRONMENT','DATADATE')


SELECT *
FROM TPS_DBA.DBO.tblSERVERSetting
WHERE SETTINGNAME IN ('DatafeedLOCATION','ENVIRONMENT','DATADATE')

