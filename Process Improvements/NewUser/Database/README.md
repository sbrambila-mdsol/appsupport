# README #


###This code will:###

	* Add a new readonly sql server login at the server lever as well as a new user at the db level
	* Update TPS_DBA permission string to account for new user

###Deployment steps:###

	* Deploy uspCreateReadOnlyUser
	
###Execution Steps:###

	*  Initialize variables:
			@TargetDatabase VARCHAR(MAX) --Database you are adding the user to 
			@ProcessingDB varchar(MAX) = NULL --Processing database where permission setting is located, defaults to NULL for use on PRD
			@UserName VARCHAR(MAX) --username for new user
			@Password VARCHAR(MAX) --password for new user
			@UserPermissionsSettingName VARCHAR(MAX) = NULL --name of user permission setting to be updated, defaults to NULL for use on PRD
	
	* EXEC TPS_DBA.dbo.uspCreateReadOnlyUser 'COHERUS_ADHOC', 'COHERUS', 'TEST_USER', '1235!#$^@$%&45863', 'userpermissions_rpt'

### Who do I talk to? ###

* Submitted by: Mike Araujo