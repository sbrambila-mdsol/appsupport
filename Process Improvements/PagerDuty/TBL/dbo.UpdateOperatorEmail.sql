USE [msdb]
GO
EXEC msdb.dbo.sp_update_operator @name=N'<Customer>', 
		@enabled=1, 
		@pager_days=0, 
		@email_address=N'ShyftProdTeam@shyftanalytics.com;cs_shyftsupport@mdsol.com', 
		@pager_address=N''
GO
