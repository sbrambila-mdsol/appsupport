/****** Script for SelectTopNRows command from SSMS  ******/
--replace customer
use <customer>
go


SELECT *
  FROM [AGD].[tblMdSetting]
  where settingname like '%email%'--ShyftProdTeam@shyftanalytics.com

  --ImmunomedicsSupport@shyftanalytics.com

  update [AGD].[tblMdSetting]
  set settingvalue=settingvalue+';ShyftProdTeam@shyftanalytics.com'
  where settingname in ('QAEmailRecipients','CSharpLoaderEmailDistro')

  UPDATE T
  set settingvalue=settingvalue+';ShyftProdTeam@shyftanalytics.com'
  --SELECT *
  FROM TPS_DBA.DBO.tblServerSetting AS T
  WHERE SETTINGNAME LIKE '%EMAIL%' AND SETTINGNAME='DefaultEmailRecepient'

  --VEEVA
  SELECT *
  FROM TPS_DBA.DBO.tblServerSetting AS T
  where settingname LIKE '%SF%'

