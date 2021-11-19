USE [msdb]
GO

IF EXISTS (SELECT NAME FROM msdb.dbo.sysoperators where name like 'pagerduty')
BEGIN
	EXEC msdb.dbo.sp_delete_operator @name=N'PagerDuty'
END

/****** Object:  Operator [PagerDuty]    Script Date: 5/1/2019 5:26:31 PM ******/
EXEC msdb.dbo.sp_add_operator @name=N'PagerDuty', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'shyft-application-services@mdsol.pagerduty.com', 
		@category_name=N'[Uncategorized]'
GO