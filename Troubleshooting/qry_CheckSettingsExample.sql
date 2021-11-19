select [AGD].[udfGetSetting] ('Fileserverlocation')
select [AGD].[udfGetSetting] ('Environment')
select [AGD].[udfGetSetting] ('DataDate')

select tps_dba.dbo.udfGetServerSetting ('Fileserverlocation')
select tps_dba.dbo.udfGetServerSetting  ('Environment')
select tps_dba.dbo.udfGetServerSetting  ('DataDate')