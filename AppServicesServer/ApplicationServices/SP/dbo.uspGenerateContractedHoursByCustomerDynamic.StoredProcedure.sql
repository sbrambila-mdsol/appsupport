USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspGenerateContractedHoursByCustomerDynamic]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspGenerateContractedHoursByCustomerDynamic]

AS

SET NOCOUNT ON

--EXEC ApplicationServices.dbo.uspGenerateContractedHoursByCustomerDynamic

--remove extra rows
DELETE
FROM [ApplicationServices_IM].[dbo].[BudgetMaster]
WHERE CUSTOMER IS NULL

--set group type when blank
update b
set grouptype=[type]
FROM [ApplicationServices_IM].[dbo].[BudgetMaster] as b
where grouptype is null

--create stage table
SELECT CUSTOMER,GROUPTYPE,
ISNULL(SUM([Mar-20]),0) as [Jan-20],
ISNULL(SUM([Mar-20]),0) as [Feb-20],
ISNULL(SUM([Mar-20]),0) as [Mar-20],
ISNULL(SUM([Apr-20]),0) as [Apr-20],
ISNULL(SUM([May-20]),0) as [May-20],
ISNULL(SUM([Jun-20]),0) as [Jun-20],
ISNULL(SUM([Jul-20]),0) as [Jul-20],
ISNULL(SUM([Aug-20]),0) as [Aug-20],
ISNULL(SUM([Sep-20]),0) as [Sep-20],
ISNULL(SUM([Oct-20]),0) as [Oct-20],
ISNULL(SUM([Nov-20]),0) as [Nov-20],
ISNULL(SUM([Dec-20]),0) as [Dec-20],
ISNULL(SUM([Jan-21]),0) as [Jan-21],
ISNULL(SUM([Feb-21]),0) as [Feb-21],
ISNULL(SUM([Mar-21]),0) as [Mar-21],
ISNULL(SUM([Apr-21]),0) as [Apr-21],
ISNULL(SUM([May-21]),0) as [May-21],
ISNULL(SUM([Jun-21]),0) as [Jun-21],
ISNULL(SUM([Jul-21]),0) as [Jul-21],
ISNULL(SUM([Aug-21]),0) as [Aug-21],
ISNULL(SUM([Sep-21]),0) as [Sep-21]
INTO #STAGE
FROM [ApplicationServices_IM].[dbo].[BudgetMaster]
WHERE GROUPTYPE IN ('AMS','PRODUCTION')
GROUP BY CUSTOMER,GROUPTYPE
ORDER BY CUSTOMER

--declare variables
DECLARE @MTHBUCKET VARCHAR(10)
DECLARE @MTH DATE
DECLARE @STRMTH VARCHAR(12)
DECLARE @STRMTH2 VARCHAR(12)
DECLARE @SQL VARCHAR(8000)
DECLARE @SQL2 VARCHAR(8000)
DECLARE @STRQTR1 VARCHAR(255) 

--set variables
SET @MTH=GETDATE()--2020-03-20
SET @STRMTH='['+LEFT(DATENAME(M,@MTH),3)+'-'+LEFT(@MTH,2)+']'
SET @STRMTH2=LEFT(DATENAME(M,@MTH),3)+'-'+LEFT(@MTH,2)
SET @STRQTR1=
CASE WHEN LEFT(@strmth2,3) IN ('Jan','Feb','Mar') THEN  '[JAN'+'-'+RIGHT(@STRMTH2,2)+']+'+'[FEB'+'-'+RIGHT(@STRMTH2,2)+']+'+'[MAR'+'-'+RIGHT(@STRMTH2,2)+']' 
	WHEN LEFT(@strmth2,3) IN ('Apr','May','Jun') THEN  '[APR'+'-'+RIGHT(@STRMTH2,2)+']+'+'[MAY'+'-'+RIGHT(@STRMTH2,2)+']+'+'[JUN'+'-'+RIGHT(@STRMTH2,2)+']' 
	WHEN LEFT(@strmth2,3) IN ('Jul','Aug','Sept') THEN  '[JUL'+'-'+RIGHT(@STRMTH2,2)+']+'+'[AUG'+'-'+RIGHT(@STRMTH2,2)+']+'+'[SEP'+'-'+RIGHT(@STRMTH2,2)+']' 
	WHEN LEFT(@strmth2,3) IN ('Oct','Nov','Dec') THEN  '[OCT'+'-'+RIGHT(@STRMTH2,2)+']+'+'[NOV'+'-'+RIGHT(@STRMTH2,2)+']+'+'[DEC'+'-'+RIGHT(@STRMTH2,2)+']'
END

--populate table
SET @SQL='
TRUNCATE TABLE ApplicationServices_IM.dbo.ContractedHoursbyCustomerDynamic
INSERT INTO ApplicationServices_IM.dbo.ContractedHoursbyCustomerDynamic(Customer,ContractedAMSHRs,ContratedbySUBHRs,TimePeriod,MappingCustomer,TableauCustomer)
SELECT CUSTOMER,SUM(CASE WHEN GROUPTYPE=''AMS'' THEN '+@STRMTH+' ELSE 0 END) AS AMS,
SUM(CASE WHEN GROUPTYPE=''Production'' THEN '+@STRMTH+' ELSE 0 END) AS Production,
'''+@strmth2+''' as CurrPrd,
CASE WHEN Customer=''Greenwich US'' then ''Greenwich'' when customer = ''Blueprint'' then ''Blueprint Medicine'' when customer = ''GSK/Tesaro'' then ''Tesaro Expansion'' when customer =''Takeda/Shire'' then ''Shire'' else Customer END,
case 
	when Customer=''Greenwich US'' then ''Greenwich'' 
	when Customer=''GSK/Tesaro'' then ''Tesaro''
	when Customer=''Takeda/Shire'' then ''Shire'' 
	else Customer 
end as TableauCustomer
FROM #STAGE
GROUP BY CUSTOMER'
--PRINT @SQL
EXEC(@SQL)

SET @SQL2='
TRUNCATE TABLE ApplicationServices_IM.dbo.ContractedHoursbyCustomerDynamicQtrly
INSERT INTO ApplicationServices_IM.dbo.ContractedHoursbyCustomerDynamicQtrly (Customer,ContractedAMSHRs,ContratedbySUBHRs,TimePeriod,MappingCustomer,TableauCustomer)
SELECT CUSTOMER,SUM(CASE WHEN GROUPTYPE=''AMS'' THEN '+@STRQTR1+' ELSE 0 END) AS AMS,SUM(CASE WHEN GROUPTYPE=''Production'' THEN '+@STRQTR1+' ELSE 0 END) AS Production,'''+@STRQTR1+''' as CurrPrd,CASE WHEN Customer=''Greenwich US'' then ''Greenwich'' when customer = ''Blueprint'' then ''Blueprint Medicine'' when customer = ''GSK/Tesaro'' then ''Tesaro Expansion'' when customer =''Takeda/Shire'' then ''Shire'' else Customer END,
case 
	when Customer=''Greenwich US'' then ''Greenwich'' 
	when Customer=''GSK/Tesaro'' then ''Tesaro''
	when Customer=''Takeda/Shire'' then ''Shire'' 
	else Customer
end as TableauCustomer
FROM #STAGE
GROUP BY CUSTOMER
'
--PRINT @SQL2
EXEC(@SQL2)


SELECT * FROM ApplicationServices_IM.dbo.ContractedHoursbyCustomerDynamic ORDER BY CUSTOMER
SELECT * FROM ApplicationServices_IM.dbo.ContractedHoursbyCustomerDynamicQtrly ORDER BY CUSTOMER
GO
