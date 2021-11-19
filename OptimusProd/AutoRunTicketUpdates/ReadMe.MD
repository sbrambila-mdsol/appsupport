Project Reference: All

###This code will:###
	Allow you to update "active" run tickets automatically via powershell. 
	Theoretically limitless actions on ticket actions.
		- AutoCloseTicket will close the active ticket for a given customer when uspJiraCloseTicket is executed on that customer's server.
		- AutoUpdateLateRun requires further development but could theoretically be used to mark a run ticket as late if the time has passed for that run's deliverable deadline.
	
###Deployment steps:###
	Step 1) Deploy powershell scripts and dbo.uspJiraCloseTicket to all servers. 
	Step 2) Setup Execution of uspJiraCloseTicket to run when all operations related to a given run ticket have completed.
	Step 3) Make sure to run appsupport\OptimusProd\Production Run Creation\TBL\dbo.ActiveRunTicketSetting.sql. This will be the ticket that gets closed.


### Who do I talk to? ###
	Submitted by: Aidan Fennessy