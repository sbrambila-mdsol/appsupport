USE MASTER
GO

SET NOCOUNT ON

IF EXISTS (SELECT NAME FROM SYS.TABLES WHERE NAME='Test') DROP TABLE Test
SELECT name,row_number() over (order by name) as RowNo
INTO TEST
FROM sys.databases
WHERE name like '%tsk%'

DECLARE @ROWNO INT
DECLARE @DBNAME VARCHAR(255)
DECLARE @SQL VARCHAR(255)

SET @ROWNO=1

WHILE @ROWNO <= (SELECT MAX(ROWNO) FROM TEST)
BEGIN
SET @DBNAME= (SELECT NAME FROM TEST WHERE ROWNO=@ROWNO)
SET @SQL='
DROP DATABASE '+@DBNAME+''
--PRINT @SQL
EXEC(@SQL)
SET @ROWNO=@ROWNO+1
END

DROP TABLE TEST