SELECT DISTINCT LEFT(NAME,PATINDEX('%20%',NAME)-2) AS NAME
INTO #TEST
FROM sys.databases AS T
WHERE name like '%_20%' and name not in ('model','msdb','tempdb','master','TPS_DBA','AgileM_APP','AgileM_RPT') and name like 'AgileM_rpt%'
ORDER BY LEFT(NAME,PATINDEX('%20%',NAME)-2)

IF EXISTS (SELECT 1 FROM sys.tables where name='Alldbs') DROP TABLE dbo.Alldbs
SELECT name,ROW_NUMBER() OVER (ORDER BY Name ASC) as RowNumMain
INTO dbo.Alldbs
FROM #TEST AS T
ORDER BY name

--SELECT * FROM dbo.Alldbs

DECLARE @CounterMain INT
DECLARE @MaxMain INT
DECLARE @DBName VARCHAR(255)

SET @CounterMain = 1
SET @MaxMain = (SELECT MAX(RowNumMain) FROM dbo.Alldbs)


WHILE @CounterMain <= @MaxMain
BEGIN
	SET @DBName=(SELECT NAME FROM dbo.Alldbs WHERE RowNumMain=@CounterMain)
	IF EXISTS (SELECT 1 FROM sys.tables where name='Stage') DROP TABLE dbo.Stage
	SELECT name,ROW_NUMBER() OVER (ORDER BY Name DESC) as RowNum
	INTO dbo.Stage
	FROM sys.databases AS T
	WHERE NAME LIKE @DBName+'_20%'


	--SELECT * FROM dbo.Stage

	--declare variables
	DECLARE @Counter INT 
	DECLARE @VCounter VARCHAR(25)
	DECLARE @SQL VARCHAR(8000)
	DECLARE @RptName VARCHAR(500)
	DECLARE @MaxID INT

	--set variables
	SET @Counter=9 --ONE MORE THAN YOU WANT TO KEEP
	SET @VCounter=CONVERT(VARCHAR(25),@COUNTER)
	SET @MaxID = (SELECT MAX(RowNum) FROM dbo.Stage)

	----REMOVE USER from active reports
	WHILE @Counter >=9 AND @Counter <= @MaxID
	BEGIN
	SET @RptName=(SELECT Name FROM dbo.Stage WHERE RowNum=@VCounter)

	SET @SQL='
	DROP DATABASE '+@RptName+''
	PRINT @SQL
	EXEC(@SQL)
	SET @COUNTER=@COUNTER+1
	SET @VCounter=CONVERT(VARCHAR(25),@COUNTER)
	END
SET @CounterMain=@CounterMain+1
SET @Counter=9
SET @VCounter=CONVERT(VARCHAR(25),@COUNTER)
SET @MaxID = (SELECT MAX(RowNum) FROM dbo.Stage)
--print 'CounterMain:'+convert(varchar(3),@countermain)
--SELECT * FROM dbo.Stage
END
DROP TABLE dbo.Stage
DROP TABLE dbo.Alldbs
DROP TABLE #TEST