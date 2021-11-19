USE <Customer>
GO

DECLARE @SQL VARCHAR(8000)
DECLARE @Customer VARCHAR(255)

--Replace customer with actual customer id i.e. 'PARATEK'
SET @Customer='<Customer>'

SET @SQL='
EXEC AGD.uspSetSetting ''ProcessingDB'','''+@Customer+'''
EXEC AGD.uspSetSetting ''DbRestore_ReportingDBName'',''XXXX''
EXEC AGD.uspSetSetting ''DbRestore_ProcessingDbName'','''+@Customer+'_[DATADATE]''
EXEC AGD.uspSetSetting ''DbRestore_AdhocDBName'','''+@Customer+'_ADHOC_[DATADATE]''
EXEC AGD.uspSetSetting ''DbRestore_IMDBName'','''+@Customer+'_Zubr_IM_[DATADATE]''
EXEC AGD.uspSetSetting ''AdhocDBName'','''+@Customer+'_ADHOC''
EXEC AGD.uspSetSetting ''IMDBName'','''+@Customer+'_Zubr_IM''
EXEC AGD.uspSetSetting ''DBBackUpFileFormat_ADHOC'','''+@Customer+'_ADHOC_[DATADATE].bak''
EXEC AGD.uspSetSetting ''DBBackUpFileFormat_IM'','''+@Customer+'_Zubr_IM_[DATADATE].bak''
EXEC AGD.uspSetSetting ''DBBackUpFileFormat_PRO'','''+@Customer+'_[DATADATE].bak''
EXEC AGD.uspSetSetting ''DBBackUpFileFormat_RPT'',''XXXX.bak''
EXEC AGD.uspSetSetting ''DBBackUpFileFolder_RPT'',''XXXX\''
EXEC AGD.uspSetSetting ''DBBackUpFileFolder_IM'','''+@Customer+'_Zubr_IM\''
EXEC AGD.uspSetSetting ''DBBackUpFileFolder_PRO'','''+@Customer+'\''
EXEC AGD.uspSetSetting ''DBBackUpFileFolder_Adhoc'','''+@Customer+'_ADHOC\''
EXEC AGD.uspSetSetting ''DBBackUpFileFolder_AdhocVerification'',''ADHOC_VERIFICATION\''
EXEC AGD.uspSetSetting ''DBBackUpFileFormat_TSK'','''+@Customer+'_TSK_[DATADATE].bak''
EXEC AGD.uspSetSetting ''DBBackUpFileFolder_TSK'','''+@Customer+'_TSK\''
EXEC AGD.uspSetSetting ''DbRestore_TSKDBName'','''+@Customer+'_TSK_[DATEDATE]''
EXEC AGD.uspSetSetting ''QAEmailRecipients'',''ShyftProdTeam@shyftanalytics.com''
EXEC AGD.uspSetSetting ''CSharpLoaderEmailDistro'',''ShyftProdTeam@shyftanalytics.com''
EXEC AGD.uspSetSetting ''DbRestore_ForceUniqueName'',''False''
'
EXEC(@SQL)

SELECT * FROM <Customer>.[AGD].[tblMdSetting]