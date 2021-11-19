/****
Helper Function

EXEC msdb.dbo.sysmail_help_configure_sp;
EXEC msdb.dbo.sysmail_help_account_sp;
EXEC msdb.dbo.sysmail_help_profile_sp;
EXEC msdb.dbo.sysmail_help_profileaccount_sp;
EXEC msdb.dbo.sysmail_help_principalprofile_sp;
****/


/****** Global settings *********/
DECLARE @defaultProfileName NVARCHAR(125), @defaultDisplayName NVARCHAR(125), @defaultSenderEmail NVARCHAR(125)
SET @defaultProfileName = 'ShyftAnalyticsEmailSystem'
SET @defaultDisplayName = 'ShyftAnalyticsEmailSystem'
SET @defaultSenderEmail = 'ShyftAnalyticsEmailSystem@shyftanalytics.com'




/****** STEP 0:  Prep the server   ***********/  
EXEC sp_configure 'show advanced options', 1; 
RECONFIGURE; 
EXEC sp_configure 'Database Mail XPs', 1; 
RECONFIGURE 

-- Stop the service
EXEC msdb.dbo.sysmail_stop_sp 
-- Start the service
EXEC msdb.dbo.sysmail_start_sp 
EXEC msdb.dbo.sysmail_help_status_sp 
-- 15MB attachment
EXEC msdb.dbo.sysmail_configure_sp 'MaxFileSize', '15000000'; 
-- Do not allow bat files as attachments
EXEC msdb.dbo.sysmail_configure_sp 'ProhibitedExtensions', 'exe,dll,vbs,js,bat'; 
-- Retry 3 times per server connection
EXEC msdb.dbo.sysmail_configure_sp  'AccountRetryAttempts', '3' ;  





/****** STEP 1:  Drop All Accounts (SMTP) on Server   ***********/
    PRINT ('STEP 1:  Drop All Accounts (SMTP) on Server ') 

	DECLARE @account_id int
	DECLARE @accountname VARCHAR(2000) 

	--DROP TABLE IF EXISTS #MailAccountToDrop
	CREATE TABLE #MailAccountToDrop (
		account_id INT 
		,accountname VARCHAR(2000)
		,accountdescription VARCHAR(5000) 
		
		,accountemailaddress VARCHAR(2000) 
		,accountdisplayname VARCHAR(2000) 
		,accountreplyto VARCHAR(2000) 
		,accountservertype VARCHAR(2000) 
		,accountservername VARCHAR(2000) 
		,accountport VARCHAR(2000) 
		,accountusername VARCHAR(2000) 
		,accountdefaultcred VARCHAR(2000) 
		,accountssl BIT 
	); 
	INSERT INTO #MailAccountToDrop(account_id  
		,accountname  
		,accountdescription 
		,accountemailaddress   
		,accountdisplayname   
		,accountreplyto  
		,accountservertype   
		,accountservername  
		,accountport  
		,accountusername  
		,accountdefaultcred  
		,accountssl   )
		EXEC msdb.dbo.sysmail_help_account_sp;

	--SELECT * FROM ##MailAccountToDrop

	DECLARE cur2 CURSOR FOR 
	SELECT account_id,accountname FROM #MailAccountToDrop

	OPEN cur2
	FETCH NEXT FROM cur2 INTO @account_id, @accountname 
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		PRINT ('DROPPING ACCOUNT: ' + @accountname)
		EXEC msdb.dbo.sysmail_delete_account_sp @account_id = @account_id;

		FETCH NEXT FROM cur2 INTO @account_id, @accountname 
	END
	CLOSE cur2
	DEALLOCATE cur2

	 


/****** STEP 2:  Adding Proofpoint Servers   ***********/
    PRINT ('STEP 2:  Adding New Proofpoint Servers') 

	EXEC msdb.dbo.sysmail_add_account_sp
		@account_name = 'Medidata Proofpoint 1',
		@description = 'Primary Medidata Proofpoint Routing point',
		@email_address = @defaultSenderEmail,
		@replyto_address = '',
		@display_name = @defaultDisplayName,
		@mailserver_name = '10.151.10.14' ; 

	EXEC msdb.dbo.sysmail_add_account_sp
		@account_name = 'Medidata Proofpoint 2',
		@description = 'Secondary Medidata Proofpoint Routing point',
		@email_address = @defaultSenderEmail,
		@replyto_address = '',
		@display_name = @defaultDisplayName,
		@mailserver_name = '10.151.56.7' ; 






/****** STEP 3:  Setup All Profiles on Server   ***********/
    PRINT ('STEP 3:  Setup All Profiles on Server ') 

	DECLARE @profile_id int, @defaultProfileFound bit
	DECLARE @profilename VARCHAR(2000), @profiledescription VARCHAR(5000)
	SET @defaultProfileFound = 0

	--DROP TABLE IF EXISTS #MailProfile
	CREATE TABLE #MailProfile (
		profile_id INT 
		,profile_name VARCHAR(2000)
		,profile_description VARCHAR(5000) 
	); 
	INSERT INTO #MailProfile(profile_id,profile_name,profile_description)
		EXEC msdb.dbo.sysmail_help_profile_sp;

	--SELECT * FROM #MailProfile

	DECLARE cur1 CURSOR FOR 
	SELECT profile_id,profile_name,profile_description FROM #MailProfile

	OPEN cur1
	FETCH NEXT FROM cur1 INTO @profile_id, @profilename,@profiledescription
	WHILE @@FETCH_STATUS = 0  
	BEGIN
		PRINT ('FOUND PROFILE: ' + @profilename)
		IF @profilename = @defaultProfileName
			SET @defaultProfileFound = 1
		
		PRINT ('ADDING PROOFPOINT 1 AND 2 RELAY')
		-- Adding SMTP primary and secondary
		EXEC msdb.dbo.sysmail_add_profileaccount_sp
			@profile_name = @profilename,
			@account_name = 'Medidata Proofpoint 1',
			@sequence_number = 1 ; 
		EXEC msdb.dbo.sysmail_add_profileaccount_sp
			@profile_name = @profilename,
			@account_name = 'Medidata Proofpoint 2',
			@sequence_number = 2 ; 
			 

		FETCH NEXT FROM cur1 INTO @profile_id, @profilename,@profiledescription
	END
	CLOSE cur1
	DEALLOCATE cur1




/****** STEP 4:  Adding Default Profile   ***********/
	IF @defaultProfileFound = 0
	BEGIN
		PRINT ('STEP 4:  Adding Default Profile') 

		EXEC msdb.dbo.sysmail_add_profile_sp
			@profile_name = @defaultProfileName,
			@description = 'ShyftAnalyticsEmailSystem Public Default Profile' ; 
	 
		EXEC msdb.dbo.sysmail_add_profileaccount_sp
			@profile_name = @defaultProfileName,
			@account_name = 'Medidata Proofpoint 1',
			@sequence_number = 1 ; 
		EXEC msdb.dbo.sysmail_add_profileaccount_sp
			@profile_name = @defaultProfileName,
			@account_name = 'Medidata Proofpoint 2',
			@sequence_number = 2 ; 
	  
		-- Set profile for public access
		EXEC msdb.dbo.sysmail_add_principalprofile_sp
			@profile_name = @defaultProfileName,
			@principal_name = 'public',
			@is_default = 1 ;
		
	END
		
		PRINT('Completed')

	-- Test it out 
	/**
		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = @defaultProfileName,
		@recipients = 'syue@shyftanalytics.com',
		@body = 'Testing',
		@subject = 'Testing' ;
		GO


		**/