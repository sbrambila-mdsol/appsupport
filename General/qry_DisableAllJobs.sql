DECLARE @SQL AS VARCHAR(MAX)

SELECT @SQL = COALESCE(@SQL+ + CHAR(13), '') + 'EXEC msdb..sp_update_job @job_name = ''' + name + ''', @enabled = 0;' FROM msdb.dbo.sysjobs
--print @sql
EXEC (@SQL)