USE TPS_DBA
GO

DROP PROCEDURE IF EXISTS [dbo].[uspInsertJobSteps]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspInsertJobSteps]
/*******************************************************************************************
Purpose:		Insert rows into tblMdJobDataProcessing and tblMdJobScenarioStep 
Inputs:		
Author:			A. Vigneau
Created:		6/5/19
Copyright:	
RunTime:	
Execution:	
				--DR job
					EXEC dbo.uspInsertJobSteps
							@JobName 				= 'Test Scenario'		
							,@IsChain 				= 0	
							,@ScenarioIDs			= '70100|80100|90100|1000'	
							,@DBNames 				= 'COE|COE|COE|COE'			
							,@DeleteUnusedSchedule	= 1
							
				--Chain job
					EXEC dbo.uspInsertJobSteps
							@JobName 		= 'Master Chain: Reporting'	
							,@IsChain 		= 1		
Helpful Selects: 		

			SELECT * FROM tblMdJobDataProcessing
			 where  jobid IN (207,211) 

			SELECT * FROM tblMdJobScenarioStep where jobid IN (207,208,210)

			SELECT * FROM tblMdJobChainMap where parentjobid IN (210)
*******************************************************************************************/
(
	 @JobName					VARCHAR(300)				-- Name of Job
	, @IsChain					BIT							-- Bit Flag to determine whether job is a Chain or DataRun. 0 is DataRun, 1 is Chain
	, @ScenarioIDs				NVARCHAR(MAX)	= NULL		-- Pipe separated list of ScenarioIDs. Required for DataRun jobs, can be left NULL otherwise
	, @DBNames					NVARCHAR(MAX)	= NULL		-- Pipe separated list of DBs. Must correspond with order of ScenarioIDs. Required for DataRun jobs, can be left NULL otherwise
	, @DeleteUnusedSchedule		BIT				= NULL		-- Big Flag to determine whether to remove existing schedule. Set to 1 to remove
)
AS
BEGIN
	SET NOCOUNT ON 

	------
	--Code Start
	--------
	BEGIN TRY
		

	--Initialize local variables
	DECLARE @ValOutput INT = 0
	DECLARE @ValErrorMessage NVARCHAR(MAX) 
	DECLARE @intCounter INT = 1
	DECLARE @vchSQL NVARCHAR(MAX)
	DECLARE @ParmDefinition NVARCHAR(250) 

	IF @DeleteUnusedSchedule IS NULL
	BEGIN
		SET @DeleteUnusedSchedule = 0
	END

	DROP TABLE IF EXISTS #tmpScenarioID
	DROP TABLE IF EXISTS #tmpDBNames
	DROP TABLE IF EXISTS #tmpJob


	SELECT IDENTITY(int, 1, 1) as ROW_ID, ScenarioID = [name] 
	INTO #tmpScenarioID
	FROM dbo.udfSplitstring  (@ScenarioIDs, '|')

	SELECT IDENTITY(int, 1, 1) as ROW_ID, DBName = [name]
	INTO #tmpDBNames
	FROM dbo.udfSplitstring (@DBNames, '|')

	SELECT s.ROW_ID, s.ScenarioID, n.DBName
	INTO #tmpJob
	FROM #tmpScenarioID s 
		JOIN #tmpDBNames n
			ON s.ROW_ID = n.ROW_ID


/******************************************************************
*******************  Validation Checks START **********************
*******************************************************************/
		
IF ISNULL(@IsChain,0)	= 0	-- If job is not chain, Scenario/DBNames required.
BEGIN

	-------------------------------
	-- Check existence of DB Name
	-------------------------------
	WHILE @intCounter <= (SELECT MAX(ROw_ID) FROM #tmpJob)

		BEGIN
			SET @vchSQL = '
				IF NOT EXISTS (SELECT db.[name]
								FROM sys.databases	 db
									JOIN #tmpJob  j
										ON db.[name] = j.DBName
									WHERE j.ROW_ID = ' + CAST(@intCounter as VARCHAR) + ')
				BEGIN
					SET @ValOutput += 1
					SET @ValErrorMessage = '' DB Name invalid''
				END

				'

				SET @ParmDefinition = N'@ValOutput INT OUTPUT, @ValErrorMessage NVARCHAR(MAX) OUTPUT'
				EXEC SP_ExecuteSQL 
						@vchSQL
						, @ParmDefinition
						, @ValOutput = @ValOutput OUTPUT
						, @ValErrorMessage = @ValErrorMessage OUTPUT;

				SET @intCounter += 1

		END

		--Throw Error here if validation fails
		IF @ValOutput > 0
		BEGIN
			RAISERROR(@ValErrorMessage, 16,1)
		END
	

-----------------------------------
-- Check existence of ScenarioType
-----------------------------------

	--reset counter
	SET @intCounter = 1


	WHILE @intCounter <= (SELECT MAX(ROw_ID) FROM #tmpJob)
	BEGIN

		--Check that scenarioID is valid in given ScenarioType table
		SET @vchSQL = '	
				IF NOT EXISTS (SELECT 1 FROM ' 
									+ (SELECT DBName FROM #tmpJob WHERE ROW_ID = @intCounter) + '.AGD.tblmdScenarioType WHERE TPSScenarioTypeID = ' + (SELECT ScenarioID FROM #tmpJob WHERE ROW_ID = @intCounter) + ')

				BEGIN
					SET @ValErrorMessage = ''ScenarioID invalid''
					SET @ValOutput += 1

				END

			'
			SET @ParmDefinition = N'@ValOutput INT OUTPUT, @ValErrorMessage NVARCHAR(MAX) OUTPUT'
			EXEC SP_ExecuteSQL 
					@vchSQL
						, @ParmDefinition
						, @ValOutput = @ValOutput OUTPUT
						, @ValErrorMessage = @ValErrorMessage OUTPUT;

			SET @intCounter += 1


	END

	IF @ValOutput > 0
		BEGIN
			RAISERROR(@ValErrorMessage, 16,1)
		END

END

	
/******************************************************************
*****************	Validation Checks END *************************
*******************************************************************/

	
	IF @ValOutput = 0
	BEGIN

		/********************************************************************************
		******************		(1.) tblMdJobDataProcessing	*****************************
		*********************************************************************************/
		
		WITH NewTableEntries AS
				(
				SELECT  JobName = @JobName
						,Active=1 
				)
			
			MERGE tblMdJobDataProcessing					t		--Target Table
			USING NewTableEntries							s		--Source Table (CTE)
				ON s.JobName = t.JobName
						
			WHEN MATCHED
				THEN UPDATE
						SET 
							t.Active	= 1
	
			WHEN NOT MATCHED BY TARGET
				THEN	INSERT 
						(	
							JobName			
							,Active
						)
						VALUES
						(	
							s.JobName			
							,Active
						);

		/********************************************************************************
		******************		(2.) tblMdJobScenarioStep	*****************************
		*********************************************************************************/
		DECLARE @JobID INT = (SELECT JobID FROM tblMdJobDataProcessing WHERE JObName = @JobName);

		IF ISNULL(@IsChain,0)	= 0	-- Fill in scenarioStep if job is not chain
		BEGIN
				WITH NewTableEntries AS
					(
					SELECT @JobID as JobID
							,*
						FROM #tmpJob 
					)
				MERGE tblMdJobScenarioStep						t		--Target Table
				USING NewTableEntries							s		--Source Table (CTE)
								ON s.JobID			= t.JobID
								AND s.DBName		= t.DatabaseName
								AND s.ScenarioID	= t.ScenarioTypeID
				WHEN MATCHED
					THEN UPDATE
							SET 
								t.StepOrder			= s.Row_ID
								,t.Active			= 1	
				WHEN NOT MATCHED BY TARGET
					THEN	INSERT 
							(	
								JobID
								,DatabaseName
								,ScenarioTypeID
								,StepOrder
								,Active
							)
							VALUES
							(	
								s.JobID
								,s.DBName
								,s.ScenarioID
								,s.Row_ID
								,1
							);

			--De-activate steps in given job that do not exist in script
				WITH NewTableEntries AS
				(
				SELECT @JobID as JobID
						,*
					FROM #tmpJob 
				)
							
				UPDATE a
				SET Active = 0
				FROM tblMdJobScenarioStep a
					LEFT JOIN NewTableEntries n
						ON a.JobID = n.JobID
						AND a.DatabaseName = n.DBName
						AND a.ScenarioTypeID = n.ScenarioID
				WHERE n.ROW_ID IS NULL
					AND a.JobID = n.JobID
					AND a.DatabaseName = n.DBName


		END


		/********************************************************************************
		******************		(3.)Chain Job Cleanup		*****************************
		*********************************************************************************/
						
		--Remove all steps in tblMdJobScenarioStep table that are attributed to chain job 
		IF ISNULL(@IsChain,0)	= 1
		BEGIN
			DELETE FROM tblMdJobScenarioStep
			WHERE JobID = @JobID
		END
		

		/********************************************************************************
		******************		(4.) Create Job				*****************************
		*********************************************************************************/
		
		EXEC	dbo.uspCreateDataProcessingJob @JobName, @DeleteUnusedSchedule
				
	END

	END TRY
	--------
	--Code End
	--------	
	
	-----------
	--Logging
	-----------	
	BEGIN CATCH

		RAISERROR(@ValErrorMessage, 16,1)

	END CATCH
	
END

GO


