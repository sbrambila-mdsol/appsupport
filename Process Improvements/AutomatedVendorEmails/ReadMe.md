README
Project reference: Greenwich / Insmed

This code will:
1) If a download scenario fails to find any files, this process will send one unique email to vendor contact with a list of files not found and their expected delivery locations.

Deployment steps:
1) Deploy the procedure, dbo.uspCreateReadOnlyUser, on the processing server for a client. 
2) Using 1_tblServerSettingInserts, Deploy and Setup 'DataDateLogic' Setting according to the DataDateLogic for your project (i.e. day behind current date).

Important Implementation Notes:
	1) Must be implemented in DOWNLOAD scenario with ContinueOnFail = 1
		* @FailScenarioWhenNotFound must be provided as input (when @FailScenarioWhenNotFound = 1 the scenario fails if 			  files are not found).
	2) Emails will not be sent about files set to IgnoreFileNotFound 
	3) Must set DataDateLogic for the relevant processing db
						
3 options for running: 
	1) Input nothing, runs for current scenario
	2) Input one or multiple scenarios, looks for files not found in each
	3) Input one vendor, looks for files not found in each scenario for that vendor

2) Ensure that necessary settings are populated with the appropriate values on client's TPS_DBA database dbo.tblServerSetting table.
    a) SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'SendVendorEmails'
    b) SELECT TOP 1 SettingValue FROM TPS_DBA.dbo.tblServerSetting where SettingName like 'DataDateLogic'
    c) SELECT SettingValue FROM TPS_DBA.dbo.tblServerSetting WHERE Settingname = 'Environment'
        *It's likely this value was updated when environments were initially set up

Execution Steps:
1) Execute the procedure on PROCESSING and provide @FailScenarioWhenNotFound and @ScenarioTypeID OR @Vendor

Who do I talk to?
Submitted by: Aidan Fennessy