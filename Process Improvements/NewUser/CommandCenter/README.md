# SupportServices

* Open the script dbo.tbldf_CommandCenterUsers from TBL folder, change to customer specific, and execute - creates import table
* Open the Procedures dbo.uspNewUserCommandCenterInserts.sql and dbo.uspUpdateCommandCenterRole.sql
	* Modify the USE command on the 1st line to match the <Customer>_TSK you need
	* Modify the insert into #newuser statement to be the <Customer>_TSK_IM you need.
* Execute the procedure dbo.uspNewUserCommandCenterInserts.sql
* Execute the procedure dbo.dbo.uspUpdateCommandCenterRole.sql
* Open the Job "Util Load New CC User".
	* Modify the appropriate customer specific items (<custabbrevprdsqlsvc>,<Customer>,<Customer_TSK>)
	* Execute the job
* Use CommandCenter to load the excel template spreadsheet CCNewUserTemplate.xlsx into the table tbldf_CommandCenterUsers in tsk_im db. Modify <Customer>_TSK_IM for the customer you need.
* This will populate the new users in tskuser and tskusrrole tables.

***Questions see Todd Forman



