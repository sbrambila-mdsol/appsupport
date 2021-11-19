# README 

#Project reference: Tesaro project story XXX-NNN

###This code will: Find values that don't meet the column definitions defined by a given tables' column character limits and output a file with the affected field, the affected value, the length of the affected value and the max length allowed by that field. This code is also configurable to automatically send an email with that file/table of affected values to business team correspondents, production team, and/or the vendor responsible for delivering the file. ###* 

TODO

###Deployment steps:
1. This code will automatically grab and declare the PROCESSING DB and the IM DB relevant to the project, no configurations are necessary asides from in the email procedure.
2. Deploy uspFindColumnOverflow on your processing server.
3a. Configure uspSendBadRecordsEmail to send an email with your desired text to your desired recipients.
3b. Deploy uspSendBadRecordsEmail on your processing server.
###

* TODO

Command to execute this procedure:
EXEC TPS_DBA.dbo.uspFindColumnOverflow '2902'   

Importantly, this procedure can be ran without providing a DataFeedID (in which case it will attempt to grab the DataFeedID associated with the most recent failed task in tblTaskQueue).

### Who do I talk to? ###

* Submitted by: Aidan Fennessy