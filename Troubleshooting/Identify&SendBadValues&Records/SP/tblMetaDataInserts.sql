		DECLARE @DBname varchar(100) = (SELECT TOP 1 TPS_DBA.dbo.udfGetArgument(Arguments, 'PROCESSINGDB') FROM [TPS_DBA].[dbo].[vwTaskQueue] WHERE statusid = 3 AND ErrorMessage <> 'A Task in parallel grouping has failed.  This task will not be executed and is being marked as Failed' order by convert(datetime, starttime) desc)

		
	--Insert tblMdScenarioType Import scenario
	DECLARE @sqlscenarioinsert nvarchar(max) = 
	'
	IF NOT EXISTS ( SELECT 1 FROM ' + @DBname + '.AGD.tblMdScenarioType WHERE TPSScenarioTypeId = 1000000 AND ScenarioTypeDescription LIKE ''Load and Find overflowing data'')
	BEGIN
		SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMdScenarioType ON
		INSERT INTO ' + @DBname + '.AGD.tblMdScenarioType 
		(TPSScenarioTypeId,	ScenarioType,	ScenarioTypeDescription)
		Values (1000000, ''Load and Find overflowing data'', ''Load and Find overflowing data'')
		SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMdScenarioType OFF
	END
	'
	EXEC (@sqlscenarioinsert)


	DECLARE @sql2 nvarchar(max) = 
	'
	IF NOT EXISTS ( SELECT 1 FROM ' + @DBname + '.AGD.tblMdDataFeed WHERE TPSScenarioTypeId = 1000000 AND ImportTableName LIKE ''tblBadData'')
	BEGIN
		SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMdDataFeed ON
		insert into ' + @DBname + '.agd.tblMdDataFeed 
							(
									 TPSDataFeedId				
									,TPSScenarioTypeId			
									,ChildFileMask				
									,IsZipFile					
									,DataFeedLocation			
									,DataFeedName				
									,DataFeedDescription		
									,LoadOrder					
									,ImportTableName			
									,StartLine					
									,DataFeedTypeId				
									,Active						
									,AppendToTable				
									,Delimiter					
									,MaxColumns					
									,WorkSheets					
									,TaskType					
									,FileDate					
									,IgnoreFileNotFound			
									,BulkInsertRowTerminator	
									,SourceId					
									,allowClientUpload			
									,DropTable	
							)
		SELECT		
									 TPSDataFeedId				=		1000000
									,TPSScenarioTypeId			=		1000000
									,ChildFileMask				=		ChildFileMask
									,IsZipFile					=		IsZipFile
									,DataFeedLocation			=		DataFeedLocation
									,DataFeedName				=		''Load and Find overflowing data''
									,DataFeedDescription		=		''Load and Find overflowing data''
									,LoadOrder					=		10
									,ImportTableName			=		''tblBadData''
									,StartLine					=		StartLine
									,DataFeedTypeId				=		DataFeedTypeId
									,Active						=		0
									,AppendToTable				=		0
									,Delimiter					=		Delimiter
									,MaxColumns					=		MaxColumns
									,WorkSheets					=		WorkSheets
									,TaskType					=		TaskType
									,FileDate					=		FileDate
									,IgnoreFileNotFound			=		0
									,BulkInsertRowTerminator	=		BulkInsertRowTerminator
									,SourceId					=		SourceId
									,allowClientUpload			=		0
									,DropTable					=		0		
					
		FROM 	' + @DBname + '.agd.tblMdDataFeed 	
		WHERE TPSDataFeedID = ' + @FailedDataFeedID + ' 
		SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMdDataFeed OFF
	END
	'
	exec (@sql2)


		DECLARE @sql7 nvarchar(max) 
	SET @sql7 = 
	'
	IF NOT EXISTS ( SELECT 1 FROM ' + @DBname + '.AGD.tblMdDataFeed WHERE TPSScenarioTypeId = 1000001 AND ImportTableName LIKE ''SELECT * FROM TPS_DBA.dbo.tblBadRecords'')
	BEGIN
		
		SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMdDataFeed ON
		insert into ' + @DBname + '.agd.tblMdDataFeed 
							(
									 TPSDataFeedId				
									,TPSScenarioTypeId			
									,ChildFileMask				
									,IsZipFile					
									,DataFeedLocation			
									,DataFeedName				
									,DataFeedDescription		
									,LoadOrder					
									,ImportTableName			
									,StartLine					
									,DataFeedTypeId				
									,Active						
									,AppendToTable				
									,Delimiter					
									,MaxColumns					
									,WorkSheets					
									,TaskType					
									,FileDate					
									,IgnoreFileNotFound			
									,BulkInsertRowTerminator	
									,SourceId					
									,allowClientUpload			
									,DropTable	
							)
		VALUES				(
									 1000001
									,1000001
									,NULL
									,0
									,''[ExtractLocation]\[Environment]\[DataDate]\BadRecords_.xlsm''
									,''Export overflowing data''
									,''Export overflowing data''
									,20
									,''SELECT * FROM TPS_DBA.dbo.tblBadRecords''
									,0
									,0
									,0
									,0
									,''XLS''
									,0
									,1
									,''ExcelExport''
									,NULL
									,0
									,NULL
									,NULL
									,NULL
									,NULL		
								)	
				SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMdDataFeed OFF

	END
	'
	--print @sql7
	EXEC (@sql7)

	
	--Insert tblMdDataRun Scenario 
	DECLARE @sql5 nvarchar(max) = 
	'
	USE ' + @DBname + '

	IF NOT EXISTS ( SELECT 1 FROM ' + @DBname + '.AGD.tblMDDatarun WHERE TPSProcessID = 1000000 AND ExecProcess LIKE ''%AGD.uspExecuteTaskManager 1%'')
	BEGIN
    
		SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMDDataRun ON
		INSERT INTO ' + @DBname + '.AGD.tblMDDataRun 
		    (   TPSProcessID,
		        ProcessName,
		        ProcessDescription,
		        FileLocation,
		        ExecProcess,
		        ExecOrder,
		        TPSExecProcessTypeID,
		        Active,
		        TPSScenarioTypeID,
		        ContinueOnFail,
		        InsertDate    )
		SELECT  TPSProcessID            = 1000000,
		        ProcessName                = ''Load and Find overflowing data'',
		        ProcessDescription        = ''Load and Find overflowing data'',
		        FileLocation            = NULL,
		        ExecProcess                = ''AGD.uspExecuteTaskManager 1'',
		        ExecOrder                = 10,
		        TPSExecProcessTypeID    = 2,
		        Active                    = 0,
		        TPSScenarioTypeID        = 1000000,
		        ContinueOnFail            = 0,
		        InsertDate                = GETDATE()     
		SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMDDataRun OFF

	END
	'
	EXEC (@sql5)

	
	--Insert tblMdDataRun Scenario 
	DECLARE @sql4 nvarchar(max) = 
	'
	USE ' + @DBname + '

	IF NOT EXISTS ( SELECT 1 FROM ' + @DBname + '.AGD.tblMDDatarun WHERE TPSProcessID = 1000001 AND ExecProcess LIKE ''%AGD.uspExecuteTaskManager 1%'')
	BEGIN
    
		SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMDDataRun ON
		INSERT INTO ' + @DBname + '.AGD.tblMDDataRun 
		    (   TPSProcessID,
		        ProcessName,
		        ProcessDescription,
		        FileLocation,
		        ExecProcess,
		        ExecOrder,
		        TPSExecProcessTypeID,
		        Active,
		        TPSScenarioTypeID,
		        ContinueOnFail,
		        InsertDate    )
		SELECT  TPSProcessID            = 1000001,
		        ProcessName                = ''Export overflowing data'',
		        ProcessDescription        = ''Export overflowing data'',
		        FileLocation            = NULL,
		        ExecProcess                = ''AGD.uspExecuteTaskManager 1'',
		        ExecOrder                = 10,
		        TPSExecProcessTypeID    = 2,
		        Active                    = 0,
		        TPSScenarioTypeID        = 1000001,
		        ContinueOnFail            = 0,
		        InsertDate                = GETDATE()     
		SET IDENTITY_INSERT ' + @DBname + '.AGD.tblMDDataRun OFF

	END
	'
	EXEC (@sql4)