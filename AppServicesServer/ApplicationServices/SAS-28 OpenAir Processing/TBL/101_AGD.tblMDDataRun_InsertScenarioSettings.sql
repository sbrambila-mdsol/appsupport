USE ApplicationServices
GO
--SELECT * FROM TESARO_CONTROLLER.agd.tblmddatarun
SET IDENTITY_INSERT AGD.tblMDDataRun OFF
SET IDENTITY_INSERT AGD.tblMDDataRun ON
SELECT * FROM agd.tblMdDataFeed

--DW/import
IF NOT EXISTS (SELECT *  FROM AGD.tblMDDataRun WHERE TPSScenarioTypeID = 2 AND TPSProcessID = 1)
INSERT	INTO	AGD.tblMDDataRun
(	   
	   TPSProcessID
      ,ProcessName
      ,ProcessDescription
      ,FileLocation
      ,ExecProcess
	  ,ExecOrder
      ,TPSExecProcessTypeID
      ,Active
	  ,TPSScenarioTypeID
	  ,ContinueOnFail
	  ,InsertDate
)
SELECT	
	   TPSProcessID				= 1
      ,ProcessName				= 'Import Open Air file'
      ,ProcessDescription		= 'Import Open Air file'
      ,FileLocation				= NULL
      ,ExecProcess				= 'AGD.uspExecuteTaskManager 1'
	  ,ExecOrder				= 10
      ,TPSExecProcessTypeID		= 2
      ,Active					= 0
	  ,TPSScenarioTypeID		= 2
	  ,ContinueOnFail			= 0
	  ,InsertDate				= GETDATE()
GO


--Push to history

IF NOT EXISTS (SELECT *  FROM AGD.tblMDDataRun WHERE TPSScenarioTypeID = 2 AND TPSProcessID = 2)
INSERT	INTO	AGD.tblMDDataRun
(	   
	   TPSProcessID
      ,ProcessName
      ,ProcessDescription
      ,FileLocation
      ,ExecProcess
	  ,ExecOrder
      ,TPSExecProcessTypeID
      ,Active
	  ,TPSScenarioTypeID
	  ,ContinueOnFail
	  ,InsertDate
)
SELECT	
	   TPSProcessID				= 2
      ,ProcessName				= 'Push file to History'
      ,ProcessDescription		= 'Push file to History'
      ,FileLocation				= NULL
      ,ExecProcess				= 'AGD.uspDatafeedtoHistory @ScenarioTypeID =2, @HistoryDataDate= ''[DATADATE][TPSRUNID]'''
	  ,ExecOrder				= 30
      ,TPSExecProcessTypeID		= 2
      ,Active					= 0
	  ,TPSScenarioTypeID		= 2
	  ,ContinueOnFail			= 0
	  ,InsertDate				= GETDATE()
GO

SET IDENTITY_INSERT AGD.tblMDDataRun OFF


SET	IDENTITY_INSERT	AGD.tblMdScenarioType ON

IF NOT EXISTS (SELECT *  FROM AGD.tblMdScenarioType WHERE TPSScenarioTypeId = 2)
BEGIN
	INSERT INTO	AGD.tblMdScenarioType
	(
			[TPSScenarioTypeId],
			[ScenarioType],
			[ScenarioTypeDescription],
			[InsertDate]
	)
	SELECT	[TPSScenarioTypeId]			= 2,
			[ScenarioType]				= 'Import OpenAir',
			[ScenarioTypeDescription]	= 'Import OpenAir',
			[InsertDate]				= GETDATE()
END
GO

SET	IDENTITY_INSERT	AGD.tblMdScenarioType OFF

