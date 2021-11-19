USE TPS_DBA
GO

IF OBJECT_ID('uspUpdatePermissionXML','P') IS NOT NULL DROP PROCEDURE dbo.uspUpdatePermissionXML
GO

CREATE PROCEDURE dbo.uspUpdatePermissionXML @Customer VARCHAR(255),@UserName VARCHAR(255),@DB VARCHAR(255)

AS

--EXEC uspUpdatePermissionXML 'IMMUNOMEDICS','JBlue','Adhoc'
--EXEC uspUpdatePermissionXML 'IMMUNOMEDICS','JBlue','IM'
--EXEC uspUpdatePermissionXML 'IMMUNOMEDICS','JBlue','PRO'
--EXEC uspUpdatePermissionXML 'IMMUNOMEDICS','JBlue','RPT'

SET NOCOUNT ON

DECLARE @SQL VARCHAR(8000)
DECLARE @SQL2 VARCHAR(8000)
DECLARE @StringValue VARCHAR(8000)
DECLARE @Settingtable VARCHAR(255)

SET @Settingtable=@CUSTOMER+'.agd.tblMdSetting'

--make a results table
DECLARE @RESULTS TABLE(VALUE VARCHAR(8000))

--insert results
SET @SQL='
SELECT left(ltrim(rtrim(settingvalue)),len(ltrim(rtrim(settingvalue)))-7) FROM '+@Settingtable+' WHERE SettingName=''UserPermissions_'+@DB+''''
INSERT INTO @RESULTS
EXEC(@SQL)

--create string for setting
SET @StringValue= (SELECT VALUE FROM @RESULTS)
SET @StringValue=LEFT(@StringValue,6)+' '+SUBSTRING(@StringValue,7,LEN(@StringValue))


--update if no settings exist
IF (SELECT * FROM @RESULTS) IS NULL
SET @SQL='
UPDATE T
SET SettingValue= ''<root> <UserPermissions><UserName>'+@UserName+'</UserName><UserRole>db_datareader</UserRole></UserPermissions> </root>''
FROM '+@Customer+'.[AGD].[tblMdSetting] AS T
WHERE SettingName = ''UserPermissions_'+@DB+''''
PRINT @SQL
EXEC(@SQL)


--update if settings exist append to them
IF (SELECT * FROM @RESULTS) IS NOT NULL
SET @SQL2='
UPDATE T
SET SettingValue='''+@StringValue+' <UserPermissions><UserName>'+@UserName+'</UserName><UserRole>db_datareader</UserRole></UserPermissions> </root>''
FROM '+@Customer+'.[AGD].[tblMdSetting] AS T
WHERE SettingName = ''UserPermissions_'+@DB+''''
PRINT @SQL2
EXEC(@SQL2)

GO



