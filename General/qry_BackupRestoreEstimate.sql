SELECT command,
s.text,
start_time,
percent_complete,
(estimated_completion_time/1000)/60.0 as "minutes to go",
dateadd(second,estimated_completion_time/1000, getdate()) as "estimated completion time"
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) s
WHERE r.command in ('RESTORE DATABASE', 'BACKUP DATABASE', 'RESTORE LOG', 'BACKUP LOG')

