USE [TPS_DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspInsertJobChainSteps]    Script Date: 4/14/2020 1:54:27 PM ******/
DROP PROCEDURE IF EXISTS [dbo].[uspInsertJobChainSteps]
GO

/****** Object:  StoredProcedure [dbo].[uspInsertJobChainSteps]    Script Date: 4/14/2020 1:54:27 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspInsertJobChainSteps]
/*******************************************************************************************
Purpose:		Insert rows into tblMdJobChainMap
Inputs:		
Author:			A. Vigneau
Created:		6/5/19
Copyright:	
RunTime:	
Execution:		
					EXEC dbo.uspInsertJobChainSteps
							@ParentJobName 		= 'Master Chain: Reporting'	
							,@ChildJobNames 	= 'Chain: Weekly Import|Test Scenario'		
Helpful Selects: 		

						SELECT * FROM tblMdJobChainMap

*******************************************************************************************/
(
	 @ParentJobName		VARCHAR(300)				-- Name of Chain Job
	,@ChildJobNames		NVARCHAR(MAX)	= NULL		-- Pipe separated list of child job names
)

AS
BEGIN
	SET NOCOUNT ON 

	------
	--Code Start
	--------
	BEGIN TRY

		DECLARE @ValErrorMessage NVARCHAR(MAX) = ''
		DECLARE @intCounter INT = 1

		DROP TABLE IF EXISTS #tmpDBNames
		DROP TABLE IF EXISTS #tmpInsert
		
		SELECT IDENTITY(int, 1, 1) as ROW_ID, ChildJobName = [name], ParentJobName =  @ParentJobName 
		INTO #tmpDBNames
		FROM dbo.udfSplitstring (@ChildJobNames, '|')

		--Validation
		WHILE @intCounter <= (SELECT MAX(ROW_ID) FROM #tmpDBNames)
		BEGIN

				IF NOT EXISTS (SELECT 1 
								FROM tblMdJobDataProcessing j
									JOIN #tmpDBnames db
										ON j.JobName = db.ParentJobName
										AND db.ROW_ID = @intCounter)
				BEGIN
					SET @ValErrorMessage = 'Parent Job Name not valid'
					RAISERROR(@ValErrorMessage, 16,1)
				END

				IF NOT EXISTS (SELECT 1 
								FROM tblMdJobDataProcessing j
									JOIN #tmpDBnames db
										ON j.JobName = db.ChildJobName
										AND db.ROW_ID = @intCounter)
				BEGIN
					SET @ValErrorMessage = 'Child Job Name not valid'
					RAISERROR(@ValErrorMessage, 16,1)
				END

				SET @intCounter += 1
		END;


		-------------
		--Insertion
		------------
				SELECT  t.ROW_ID, j2.JobID as ParentID, j.jobid as ChildID
				INTO #tmpInsert
					FROM #tmpDBNames t
						JOIN tblMdJobDataProcessing j
							ON j.JobName = t.ChildJobName
						JOIN tblMdJobDataProcessing j2
							ON j2.JobName = t.ParentJobName
				
			
				DELETE m
					FROM tblMdJobChainMap m
						JOIN  #tmpInsert t
							ON m.parentjobid = t.parentid 

				INSERT INTO tblMdJobChainMap 
				(
					ChildJobID
					,ParentJobID
					,JobOrder
				)
				SELECT ChildID, ParentID, Row_ID
					FROM #tmpInsert
			



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


