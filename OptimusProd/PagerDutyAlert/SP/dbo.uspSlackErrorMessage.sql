USE TPS_DBA
GO

DROP PROCEDURE IF EXISTS dbo.uspSlackErrorMessage
GO

CREATE PROCEDURE dbo.uspSlackErrorMessage (@Message nvarchar(max), @Notify nvarchar(max) = '', @Message2 nvarchar(max) = '')
AS
BEGIN
  DECLARE @ReturnCode INT
  SELECT @ReturnCode = 0

  IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
    BEGIN
    EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
    END

  DECLARE @jobName nvarchar(200) = 'Slack Message ' + CONVERT(nvarchar(100),newid())
  DECLARE @servername nvarchar(200) = @@SERVERNAME
  DECLARE @timestamp nvarchar(200) = convert(varchar, getdate(), 22)	

  DECLARE @cmd nvarchar(max) = N'
  [Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
  $cmd=hostname
  $Body_Text="'+@servername+': '+@Message+''+@timestamp+''+@Message2+''+@Notify+'"
  $SlackChannel=invoke-sqlcmd "select settingvalue from TPS_DBA.dbo.tblserversetting where settingname=''SlackFailChannel''"
  $SlackChannel=$SlackChannel.settingvalue -split ","

  foreach($channel in $SlackChannel){
  if ($SlackChannel -ne $null ){
  $SlackUser=invoke-sqlcmd "select settingvalue from TPS_DBA.dbo.tblserversetting where settingname=''SlackBotName''"
  $SlackURL=invoke-sqlcmd "select settingvalue from TPS_DBA.dbo.tblserversetting where settingname=''SlackURL''"
  $SlackIcon=invoke-sqlcmd "select settingvalue from TPS_DBA.dbo.tblserversetting where settingname=''SlackIcon''"

  $payload = @{
	"channel" = $channel
	"icon_emoji" = $SlackIcon.settingvalue 
	"text" = " $Body_Text"
	"username" = $SlackUser.settingvalue
  }
  TRY{
  Invoke-WebRequest `
	-Body (ConvertTo-Json -Compress -InputObject $payload) `
	-Method Post `
	-Uri  $SlackURL.settingvalue| Out-Null -ErrorAction Stop
  }
  Catch {Write-Host "Failed to Post Slack Message"}
    } else {exit}
  }'

  DECLARE @jobId BINARY(16)
  EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=@jobName, 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=3, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@job_id = @jobId OUTPUT

  EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Slack Message', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=1, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=@cmd, 
		@database_name=N'master', 
		@flags=0

  EXEC msdb.dbo.sp_add_jobserver @job_id=@jobId, @server_name =@servername

  EXEC msdb.dbo.sp_start_job @job_name= @jobName

END
GO