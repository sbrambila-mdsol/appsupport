USE [TPS_DBA]
GO

drop procedure if exists [dbo].[uspJiraCloseTicket]
/****** Object:  StoredProcedure [dbo].[uspJiraCloseTicket]    Script Date: 7/16/2019 1:54:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspJiraCloseTicket]
/*******************************************************************************************
Name:               uspJiraCloseTicket
Purpose:            Closes and updates the active run ticket when run.
Inputs:             None
Author:             Aidan Fennessy
Created:            2nd May 2019
History:            Date                Name                Comment
                    2nd May 2019		Aidan Fennessy		Initial Creation

Copyright:
RunTime:            00:00:00 (HH:MM:SS)

Execution:          EXEC TPS_DBA.dbo.uspJiraCloseTicket 
NOTES:


 USEFUL SELECTS:

					
*******************************************************************************************/

AS
BEGIN

SET NOCOUNT OFF

		DECLARE @server VARCHAR(100) = @@servername 
		DECLARE @PshellString VARCHAR(1000) 
		DECLARE @rc VARCHAR(1000) 
		DECLARE @doc varchar(max) = ''
		DECLARE @line varchar(255)
		
	
		/* Close and update JIRA Ticket */
		IF 
		(@server LIKE 'PRO%' or @server like 'PRD%') --MAKE SURE THAT WE ARE RUNNING ON THE PROCESSING ENVIRONMENT 
		BEGIN
			set @PshellString=N'%WINDIR%\System32\WindowsPowerShell\v1.0\powershell.exe C:\PowerShellScripts\AutoCloseTicket.ps1'--'powershell.exe C:\PowerShellScripts\AutoAutoBot.ps1'
			IF OBJECT_ID('TPS_DBA.dbo.tblCmdShellOutput', 'U') IS NULL
				BEGIN
					CREATE TABLE TPS_DBA.dbo.tblCmdShellOutput (id int identity(1,1), output nvarchar(max) null, InsertDate datetime DEFAULT CURRENT_TIMESTAMP)
				END

			CREATE TABLE #output (line varchar(255))
			INSERT #output (line) exec @rc = master..xp_cmdshell @PshellString
				
				--log output
				DELETE FROM #output WHERE line IS NULL
				
				DECLARE l_cursor CURSOR
				FOR SELECT line FROM #output
				
				OPEN l_cursor
				
				FETCH NEXT FROM l_cursor INTO @line
				
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @doc = @doc + @line
					FETCH NEXT FROM l_cursor INTO @line
				END
				
				CLOSE l_cursor
				DEALLOCATE l_cursor
				DROP TABLE #output

			INSERT INTO TPS_DBA.dbo.tblCmdShellOutput (output) select @doc
			--INSERT TPS_DBA.dbo.tblCmdShellOutput (output) exec @rc = master..xp_cmdshell @PshellString
			SELECT * FROM TPS_DBA.dbo.tblCmdShellOutput WHERE output IS NOT NULL ORDER BY id


        END


	/*	IF 
		(@server LIKE 'PRO%' or @server like 'PRD%') --MAKE SURE THAT WE ARE RUNNING ON THE PROCESSING ENVIRONMENT 
	--	AND (SELECT DISTINCT * FROM TPS_DBA.dbo.tblRunTickets WHERE [Epic Link] like 'CSP-1' AND Active = 1 AND Deliverable = '')  
		BEGIN
			set @PshellString=N'%WINDIR%\System32\WindowsPowerShell\v1.0\powershell.exe C:\PowerShellScripts\AutoUpdateLateRun.ps1'--'powershell.exe C:\PowerShellScripts\AutoAutoBot.ps1'
			IF OBJECT_ID('TPS_DBA.dbo.tblCmdShellOutput', 'U') IS NULL
				BEGIN
					CREATE TABLE TPS_DBA.dbo.tblCmdShellOutput (id int identity(1,1), output nvarchar(255) null, InsertDate datetime DEFAULT CURRENT_TIMESTAMP)
				END
			INSERT TPS_DBA.dbo.tblCmdShellOutput (output) exec @rc = master..xp_cmdshell @@PshellString
			SELECT * FROM TPS_DBA.dbo.tblCmdShellOutput WHERE output IS NOT NULL ORDER BY id
		END
	*/
		
RETURN 

END	




GO
