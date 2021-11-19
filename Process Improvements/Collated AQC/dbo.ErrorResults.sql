USE [TPS_DBA]
GO

DROP TABLE IF EXISTS [dbo].#TMPerrorresults 
SELECT ServerName,	JobName,	StepName,	SystemError,	SystemCommand,	DatabaseName,	ScenarioTypeID,	TaskQueueID,	TaskStartTime,	TaskEndTime,	TaskQueueError,	RunID,	Datadate,	ImportID,	FilePath,	ImportTableName, 'Not Available' as ImportedFileName, DatafeedID,	RecordsLoaded,	ImportErrorMessage,	SFobject,	SFid,	SFerror,	SFTPpath,	SFTPUsername,	SFTPpassword,	ChildFileMask,	IsZipFile,	DataFeedLocation,	DataFeedName,	DataFeedDescription,	LoadOrder,	StartLine,	DataFeedTypeID,	Active,	AppendToTable,	Delimiter,	MaxColumns,	Worksheets,	TaskType,	FileDate,	IgnoreFileNotFound,	DropTable,	QAqueryID,	QAresult,	ExpectedQAresult,	QueryDescription,	QAquery,	FailThreshold,	QAinsertDate,	JiraTicket,	errorID INTO [dbo].#TMPerrorresults  FROM  [dbo].[ErrorResults] 

DROP TABLE IF EXISTS [dbo].[ErrorResults] 

/****** Object:  Table [dbo].[ErrorResults]    Script Date: 1/21/2020 5:29:21 PM ******/
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

CREATE TABLE [dbo].[ErrorResults](
	[ServerName] [varchar](50) NULL,
	[JobName] [varchar](max) NULL,
	[StepName] [varchar](max) NULL,
	[SystemError] [varchar](max) NULL,
	[SystemCommand] [varchar](max) NULL,
	[DatabaseName] [varchar](500) NULL,
	[ScenarioTypeID] [varchar](25) NULL,
	[TaskQueueID] [varchar](25) NULL,
	[TaskStartTime] [varchar](255) NULL,
	[TaskEndTime] [varchar](255) NULL,
	[TaskQueueError] [nvarchar](max) NULL,
	[RunID] [varchar](25) NULL,
	[Datadate] [varchar](255) NULL,
	[ImportID] [varchar](25) NULL,
	[FilePath] [varchar](7000) NULL,
	[ImportTableName] [varchar](1000) NULL,
	[ImportedFileName] [varchar](1000) NULL,
	[DatafeedID] [varchar](25) NULL,
	[RecordsLoaded] [varchar](25) NULL,
	[ImportErrorMessage] [nvarchar](max) NULL,
	[SFobject] [varchar](512) NULL,
	[SFid] [varchar](512) NULL,
	[SFerror] [varchar](max) NULL,
	[SFTPpath] [varchar](max) NULL,
	[SFTPUsername] [varchar](max) NULL,
	[SFTPpassword] [varchar](max) NULL,
	[ChildFileMask] [varchar](250) NULL,
	[IsZipFile] [varchar](25) NULL,
	[DataFeedLocation] [varchar](max) NULL,
	[DataFeedName] [varchar](max) NULL,
	[DataFeedDescription] [varchar](max) NULL,
	[LoadOrder] [varchar](25) NULL,
	[StartLine] [varchar](25) NULL,
	[DataFeedTypeID] [varchar](25) NULL,
	[Active] [varchar](25) NULL,
	[AppendToTable] [varchar](25) NULL,
	[Delimiter] [varchar](50) NULL,
	[MaxColumns] [varchar](25) NULL,
	[Worksheets] [varchar](50) NULL,
	[TaskType] [varchar](50) NULL,
	[FileDate] [varchar](50) NULL,
	[IgnoreFileNotFound] [varchar](25) NULL,
	[DropTable] [varchar](25) NULL,
	[QAqueryID] [varchar](25) NULL,
	[QAresult] [varchar](25) NULL,
	[ExpectedQAresult] [varchar](25) NULL,
	[QueryDescription] [varchar](max) NULL,
	[QAquery] [varchar](max) NULL,
	[FailThreshold] [varchar](25) NULL,
	[QAinsertDate] [varchar](25) NULL,
	[JiraTicket] [varchar](max) NULL,
	[errorID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]


INSERT INTO TPS_DBA.dbo.ErrorResults SELECT ServerName,	JobName,	StepName,	SystemError,	SystemCommand,	DatabaseName,	ScenarioTypeID,	TaskQueueID,	TaskStartTime,	TaskEndTime,	TaskQueueError,	RunID,	Datadate,	ImportID,	FilePath,	ImportTableName, ImportedFileName, DatafeedID,	RecordsLoaded,	ImportErrorMessage,	SFobject,	SFid,	SFerror,	SFTPpath,	SFTPUsername,	SFTPpassword,	ChildFileMask,	IsZipFile,	DataFeedLocation,	DataFeedName,	DataFeedDescription,	LoadOrder,	StartLine,	DataFeedTypeID,	Active,	AppendToTable,	Delimiter,	MaxColumns,	Worksheets,	TaskType,	FileDate,	IgnoreFileNotFound,	DropTable,	QAqueryID,	QAresult,	ExpectedQAresult,	QueryDescription,	QAquery,	FailThreshold,	QAinsertDate,	JiraTicket,	errorID 
FROM TPS_DBA.DBO.#TMPerrorresults

