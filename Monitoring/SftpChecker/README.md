# SupportServices

* Make sure winscp is installed on the Production server in the following path: C:\"Program Files (x86)"\WinSCP
* Open script from job folder dbo.SftpChecker.sql on production server in sql server
* Update <customer>, <PRDServer>, <Password> values in above script
* Run above script
* Open job SFTP Checker and add schedule to run every 30 min starting at midnight
* Add email failure notification operator to the job
* Save job
 

