This is the repo where Optimus Prod will live. A couple items of note:

1. Released Versions:
	Released Versions will live in L:\Application Services\Optimus Prod\Release
2. Usage/Installation
	Copy the .Exe from the L drive to your local machine (workspace only), anywhere will do. Run as normal.
	Logs will be created in a folder in the same location, titled OptimusProdLogs, a log file will go there.
3. New Customers (Get Excited!)
	Please add new customers to the [PROSHFASDB1].[ApplicationServices].[dbo].[tblMDServers] table

4. Updates/Changes (Mike, Aidan,this is for you)
	1. Any changes to the code should be reviewed and tested by peers before "Release"
	2. Updates to the PowerShell code should not require a re-signing of the code, however, to do so, use the signing tool and resign the code. (located in the Code Signing Tool Directory)
	3. Any updates to the code in the PowerShell will need to be compiled. This is done using the "RunMeToCompile.ps1" code in the same directory. Please update the version number in the RunMeToCompile code accordingly.
	4. Once updated,the EXE will need to be resigned, as it's net new, use the signing tool to do so.
	5. Please document all changes thoroughly via tickets on the App Services board, and clear, commented, pull requests.
