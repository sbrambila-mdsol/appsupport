--ALTER DATABASE tempdb ADD FILE ( NAME = N'tempdev2',
--FILENAME = N'D:\Data\tempdev2.ndf' , SIZE = 512MB , FILEGROWTH = 256MB)
--GO

DECLARE @SQL VARCHAR(8000)
DECLARE @COUNTER INT
DECLARE @STRCOUNTER VARCHAR(2)

SET @COUNTER=2
SET @STRCOUNTER=CONVERT(VARCHAR(2),@COUNTER)

WHILE @COUNTER <=8
BEGIN
SET @SQL='
ALTER DATABASE tempdb ADD FILE ( NAME = N''tempdev'+@STRCOUNTER+''',
FILENAME = N''F:\MSSQL\DATA\tempdev'+@STRCOUNTER+'.ndf'' , SIZE = 5MB , FILEGROWTH = 10%)
'
EXEC(@SQL)
PRINT @SQL
SET @COUNTER=@COUNTER+1
SET @STRCOUNTER=CONVERT(VARCHAR(2),@COUNTER)
END

