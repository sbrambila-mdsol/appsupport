Under tbl folder:
1. Update <customer> and Execute dbo.tblDCRTableCreation.sql - this will create the base staging tables
2. Update <customer> and Execute dbo.tblVeevaScenarioInsert - this creates the new scenario if it doesn't exist already
3. Update <customer> and Execute dbo.tblVeevaDataFeed.sql - this will add the datafeed rows of the tables to bring down the associated tables from veeva for DCR  and DCR Line item. Added BPM_Web_Lead_Suggestion__c as well.
4. Update <customer> and Execute dbo.tblVeevaUpdates.sql - this will add the datafeed rows for the views we will push back to Veeva (Account,DCR, DCR Line item)
5. Update <customer_IM> and Execute dbo.tblDCRValidTableCreation.sql - this will create the staging valid tables
6. Update <customer> and <abbr> and Execute dbo.tblImportValidDCR.sql - this will create the scenarios, datafeeds,dataruns to push the valid records up to Veeva

Under vw folder:
1. Update <customer> and Execute dbo.DCRCreateViews - this will install the views we push to veeva

Under sp folder: Update customer prior to execution
1. Execute dbo.uspProcessDCRPrimaryParent - this is the main sproc to run the PrimaryParent requests (called in jobUtilRefreshVeevaDCR)
2. Execute dbo.uspUpdateVeevaPrimaryParentDCR - this will process the data back to Veeva (called in jobUtilPushVeevaDCRPrimParent)
3. Execute dbo.uspUpdatePrimaryParentDCRValidationFlags - this will update the validation flags in our staging table to push to veeva
4. Execute dbo.uspImportValidDCRPrimaryParent - this will import the valid primary parents records into a staging table for update

Under job folder: Update Customer and Cust abbv prior to execution
1. Execute dbo.jobUtilRefreshVeevaDCR - this will pull down the DCR and DCR Line item requests and stage records to review
2. Execute dbo.jobUtilPushVeevaDCRPrimParent - this will push the updates back to veeva

Under Template folder:
1. Copy this template DCRValidRecords.xlsx to the path \\prd<custabbrev>10db1\Development\DCR. You may need to create the DCR folder


--process outlined:
1. Run Job Util Refresh Veeva DCR (After testing will remove refresh step and just do the processing step)
2. Run these queries and copy to excel spreadsheet with a valid of 1 found here \\PRD<custabb>10DB1\Development\DCR\DCRValidRecords.xlsx: (after testing will move to a processing folder)
SELECT * FROM <customer>.DBO.tblstgVeevaDataChangeRequest
SELECT * FROM <customer>.DBO.tblstgVeevaDataChangeRequestLine
SELECT * FROM <customer>.DBO.tblstgVeevaAccountDCR
3. Save and close excel file 
4. Run Job Util Push Veeva DCR PrimParent