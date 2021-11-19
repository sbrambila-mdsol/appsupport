Under tbl folder:
1. Execute dbo.tblDCRTableCreation.sql - this will create the base staging tables
3. Execute dbo.tblVeevaUpdates.sql - this will add the datafeed rows for the views we will push back to Veeva (Credential)
4. Execute dbo.tblDCRValidTableCreation.sql - this will create the staging valid tables
5. Execute dbo.DSHistoryDCRItems.sql - this will create the dcr header table 
6. Execute dbo.stgPotentialMisMatches.sql - this will create the address mismatch table

Under vw folder:
1. Execute dbo.DCRCreateViews - this will install the views we push to veeva

Under sp folder:
1. Execute dbo.uspProcessDCRCredential - this is the main sproc to run the Credential requests (called in jobUtilRefreshVeevaDCR)
2. Execute dbo.uspUpdateVeevaCredentialDCR - this will process the data back to Veeva (called in jobUtilPushVeevaDCRCredential )
3. Execute dbo.uspUpdateCredential CRValidationFlags - this will update the validation flags in our staging table to push to veeva
4. Execute dbo.uspImportValidDCRCredential - this will import the valid Credential records into a staging table for update
5. Execute dbo.uspAddressMismatches.sql - this will run the address mismatch process
6. Execute dbo.DSHistoryDCRItems.sql - this will update the dcr history table


Under job folder:
1. Execute dbo.jobUtilRefreshVeevaDCR - this will pull down the DCR and DCR Line item requests, run address mismatches, and process DCR entries
2. Execute dbo.jobUtilPushVeevaDCRCredential - this will push the updates back to veeva

