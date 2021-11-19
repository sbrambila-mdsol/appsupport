# README #

Project reference:  COHERUS

Questions: Aidan Fennessy, Todd Forman

###This code will:###

	* uspCreateJob Will Create a job with each separate step determined by a semicolon when executing the procedure. After inputting your code, Find-and-Replace all instances of apostrophes <'> with two apostrophes <''> but keep the first and last apostrophe in the string.
	* uspGenerateAutoChainJob will create a job using uspCreateJob, referencing tblAutomatedJobBuild to create a chain that will run the jobs provided as input in tblAutomatedJobBuild.
		1. Execute the script in TBL folder to create the table tblAutomatedJobBuild. 
		2. Execute the scripts in SP folder. 
		3. Insert jobs you want to build in the table tblAutomatedJobBuild. 
			Note: Please make sure to truncate the table before each chain job you want to build. 
		4. Execute the sproc dbo.uspGenerateAutoChainJob passing in the name of the Autojob you want to create. 
			e.g. exec uspGenerateAutoChainJob 'Command Center jobs'. 

E.g.
EXEC TPS_DBA.DBO.uspCreateJob
'  ----Keep this single apostrophe
EXEC TPS_DBA.dbo.uspStartJobWait ''CHAIN: Veeva Import - MDM''
|
EXEC TPS_DBA.dbo.uspStartJobWait ''CHAIN: Monday Reporting Chain''
|
print ''test''
|
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_id=N''10e29f3b-e171-413b-8de8-f6e0ad0a0d55'', 
		@enabled=1

GO
|
EXEC TPS_DBA.dbo.uspStartJobWait ''Update Data Date''
'   ----Keep this single apostrophe

###Deployment steps:###
