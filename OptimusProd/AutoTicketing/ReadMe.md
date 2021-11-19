Project Reference: All

###This code will:###
	dbo.uspFindLatestErrorInfo is executed by OptimusProd and AutoAutoBot to find the latest error information.
	AutoAutoBot will automatically create a ticket upon failure. OptimusProd is for assisted manual creation of tickets. 
	
###Deployment steps:###
	Step 1) Deploy dbo.uspFindLatestErrorInfo to all servers (ancient version to pre-3x projects). 
	Step 2) Deploy AutoAutoBot.ps1 to all servers using CMSCodeDeploy\DeployCode9000
	Step 3) Deploy dbo.IssueTicketAssignee from the TBL folder to add the setting for the issue assignee
	Step 4) Deploy dbo.JiraProjectName from the TBL folder to add the setting for Jira Project Name


### Who do I talk to? ###
	Submitted by: Aidan Fennessy