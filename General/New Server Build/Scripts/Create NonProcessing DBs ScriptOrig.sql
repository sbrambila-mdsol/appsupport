	
	/************************************************************************************************************************************************
																Script Purpose
	*************************************************************************************************************************************************/
	--	This script creates the non-processing databases (ie. the "_IM" database and the "_ADHOC" database). 
	--	It assumes that (1.) TPS_DBA is installed and (2.) that the Processing DB's have been created (or, at the very least, that the generic "ClientName" DB prefix has been agreed upon)
			
	/************************************************************************************************************************************************
																	Steps
	*************************************************************************************************************************************************/	
	--	1. Simply type in your Client Name (ie. the name that you chose for the main processing DB) after the variable @ClientName, below. Then excute the whole script

	DECLARE @ClientName VARCHAR(30) 
	SET @ClientName = 'SCYNEXIS'

	--------------------------------------------------------------------------------------------------------------------------------------------------

	DECLARE @ADHOCdbName	VARCHAR(100)	= @ClientName + '_ADHOC'
	DECLARE @IMdbName		VARCHAR(100)	= @ClientName + '_IM'

	--Creates Adhoc DB
	--EXEC TPS_DBA.dbo.uspTPS_CreateDB	@DBName		= @ADHOCdbName

	--Creates IM DB
	EXEC TPS_DBA.dbo.uspTPS_CreateDB	@DBName		= @IMdbName
	

	
	