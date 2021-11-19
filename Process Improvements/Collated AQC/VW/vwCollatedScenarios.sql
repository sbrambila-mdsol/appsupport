USE [TPS_DBA]
GO

/****** Object:  View [dbo].[vwCollatedScenarios]    Script Date: 1/14/2020 1:02:49 PM ******/
DROP VIEW IF EXISTS [dbo].[vwCollatedScenarios]
GO

/****** Object:  View [dbo].[vwCollatedScenarios]    Script Date: 1/14/2020 1:02:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


	CREATE VIEW [dbo].[vwCollatedScenarios]

	AS

	
    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE 'ClientName') AS Customer, '<Customer>' AS 'Database'	
				,TPSScenarioTypeId	
				,ScenarioType	
				,ScenarioTypeDescription					
		FROM	<Customer>.agd.tblMdScenarioType
		

 UNION ALL 


    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE 'ClientName') AS Customer, '<Customer>_CM' AS 'Database'	
				,TPSScenarioTypeId	
				,ScenarioType	
				,ScenarioTypeDescription					
		FROM	<Customer>_CM.agd.tblMdScenarioType
		

 UNION ALL 


    SELECT (SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE SettingName LIKE 'ClientName') AS Customer, '<Customer>_AGG' AS 'Database'	
				,TPSScenarioTypeId	
				,ScenarioType	
				,ScenarioTypeDescription					
		FROM	<Customer>_AGG.agd.tblMdScenarioType
		

	
GO


