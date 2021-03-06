USE [master]
GO

DECLARE @SQL VARCHAR(8000)
DECLARE @SERVER VARCHAR(255)

SET @SERVER='<server>'

SET @SQL='

EXEC master.dbo.sp_addlinkedserver @server = N'''+@SERVER+''', @srvproduct=N''SQL Server''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''collation compatible'', @optvalue=N''false''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''data access'', @optvalue=N''true''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''dist'', @optvalue=N''false''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''pub'', @optvalue=N''false''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''rpc'', @optvalue=N''true''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''rpc out'', @optvalue=N''true''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''sub'', @optvalue=N''false''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''connect timeout'', @optvalue=N''0''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''collation name'', @optvalue=null

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''lazy schema validation'', @optvalue=N''false''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''query timeout'', @optvalue=N''0''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''use remote collation'', @optvalue=N''true''

EXEC master.dbo.sp_serveroption @server=N'''+@SERVER+''', @optname=N''remote proc transaction promotion'', @optvalue=N''true''

USE [master]

EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'''+@SERVER+''', @locallogin = NULL , @useself = N''False'', @rmtuser = N''AgileDWorkbenchRestricted'', @rmtpassword = N''U!tzUFiO!KmM''
'
--PRINT @SQL
EXEC(@SQL)
