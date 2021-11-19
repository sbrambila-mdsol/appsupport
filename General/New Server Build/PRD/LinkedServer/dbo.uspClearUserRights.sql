USE [TPS_DBA]
GO

IF OBJECT_ID('uspClearUserRights','P') IS NOT NULL DROP PROCEDURE [dbo].[uspClearUserRights]
GO


CREATE PROCEDURE dbo.uspClearUserRights (@UserGroup VARCHAR(255))

AS

/*******************************************************************************************
Purpose: To remove all rights to a specific user at the database level
Inputs:		
Author:	Todd Forman	
Created: 03/05/19	
Copyright:	Today
RunTime:	
Execution:	
		EXEC dbo.uspClearUserRights 'AgileDWorkbenchRestricted'
		EXEC dbo.uspClearUserRights 'TPSINTERNAL\EC2 BA Group'
		EXEC dbo.uspClearUserRights 'TPSINTERNAL\EC2 DB Group'					
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM 
					
					---- Staging Tables:
						SELECT * FROM 

					---- Reporting Tables:
						SELECT * FROM 
						



*******************************************************************************************/

SET NOCOUNT ON


--get list of db's to loop through
SELECT name,row_number() over (order by name) as rownum
INTO #test
FROM sys.databases

--declare/set variables
DECLARE @rowno int
SET @rowno = 1
DECLARE @sql varchar(8000)
DECLARE @db varchar(255)

--loop through db's and drop user
WHILE @rowno <= (select max(rownum) from #test)
BEGIN
SET @db=(select name from #test where rownum=@rowno)

SET @sql='
use '+@db+'
DROP USER ['+@UserGroup+']'
--PRINT @sql
EXEC(@sql)
SET @rowno=@rowno+1
END

DROP TABLE #Test

