USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspAddCustomerToQAdashboard]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Mike Araujo
-- Create date: 11/29/2019
-- Description:	Add Customer to QA Dashboard 

-- Can reset a customer on the dashboard by supplying a value for @CustomerName 
-- and the correspnding value for @CustSchema
-- =============================================
CREATE PROCEDURE [dbo].[uspAddCustomerToQAdashboard]
(
	@CustSchema VARCHAR(50),
	@CustomerName VARCHAR(100) = NULL
)

	
AS
BEGIN
SET NOCOUNT ON;
select * from dbo.QA_last10_all_servers
DECLARE @sql VARCHAR (5000)

SET @sql = 'delete from dbo.QA_last10_all_servers where customer = ''' +  @CustomerName + ''''
EXEC (@sql)
SET @sql = 'delete from dbo.QA_scenario_all_servers where customer = ''' +  @CustomerName + ''''
EXEC (@sql)
SET @sql = 'delete from dbo.QA_all_servers where customer = ''' +  @CustomerName + ''''
EXEC (@sql)
SET @sql = 'delete from dbo.QA_errors_all_servers where customer = ''' +  @CustomerName + ''''
EXEC (@sql)

SET @sql = 
'INSERT INTO [dbo].[QA_errors_all_servers]
           ([Customer]
           ,[Database]
           ,[TPSScenarioTypeId]
           ,[FailedAQCQueryIDs]
           ,[InsertDate])
SELECT 
			[Customer]
           ,[Database]
           ,[TPSScenarioTypeId]
           ,[FailedAQCQueryIDs]
           ,[InsertDate]
FROM StrataLogs.' + @CustSchema + '.[vwCollatedErroredAQC]'
EXEC (@sql)

SET @sql = 
'INSERT INTO [dbo].[QA_scenario_all_servers]
           ([Customer]
           ,[Database]
           ,[TPSScenarioTypeId]
           ,[ScenarioType]
           ,[ScenarioTypeDescription])
SELECT
			[Customer]
           ,[Database]
           ,[TPSScenarioTypeId]
           ,[ScenarioType]
           ,[ScenarioTypeDescription]
FROM StrataLogs.' + @CustSchema + '.[vwCollatedScenarios]'
EXEC (@sql)

SET @sql = 
'INSERT INTO [dbo].[QA_all_servers]
           ([Customer]
           ,[Database]
           ,[QueryID]
           ,[TPSRunID]
           ,[QueryType]
           ,[QueryName]
           ,[AlertType]
           ,[WarnThreshold]
           ,[FailThreshold]
           ,[ExpectedResult]
           ,[CurrentDataDate]
           ,[CurrentResult]
           ,[PriorResult]
           ,[PriorDataDate]
           ,[PercentChange]
           ,[TPSQueryID]
           ,[TPSScenarioTypeId]
           ,[avg_results]
           ,[STD_DEV]
           ,[LOWER_BOUND]
           ,[UPPER_BOUND]
           ,[Query]
           ,[Failure]
           ,[Warning]
           ,[InsertDate])
SELECT 
			[Customer]
           ,[Database]
           ,[QueryID]
           ,[TPSRunID]
           ,[QueryType]
           ,[QueryName]
           ,[AlertType]
           ,[WarnThreshold]
           ,[FailThreshold]
           ,[ExpectedResult]
           ,[CurrentDataDate]
           ,[CurrentResult]
           ,[PriorResult]
           ,[PriorDataDate]
           ,[PercentChange]
           ,[TPSQueryID]
           ,[TPSScenarioTypeId]
           ,[avg_results]
           ,[STD_DEV]
           ,[LOWER_BOUND]
           ,[UPPER_BOUND]
           ,[Query]
           ,[Failure]
           ,[Warning]
           ,[InsertDate]
FROM StrataLogs.' + @CustSchema + '.[vwCollatedQAResults]'
EXEC (@sql)

SET @sql = 
'INSERT INTO [dbo].[QA_last10_all_servers]
           ([Customer]
           ,[Database]
           ,[row_num]
           ,[TPSRunId]
           ,[QueryID]
           ,[TPSScenarioTypeId]
           ,[Result]
           ,[DataDate]
           ,[Query]
           ,[InsertDate]
           ,[ExpectedResult]
           ,[Failure]
           ,[Warning])
SELECT
			[Customer]
           ,[Database]
           ,[row_num]
           ,[TPSRunId]
           ,[QueryID]
           ,[TPSScenarioTypeId]
           ,[Result]
           ,[DataDate]
           ,[Query]
           ,[InsertDate]
           ,[ExpectedResult]
           ,[Failure]
           ,[Warning]
FROM StrataLogs.' + @CustSchema + '.[vwCollatedTopTenQAResults]'
EXEC (@sql)

END
 
GO
