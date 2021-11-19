SELECT 
                s.session_id
                ,s.host_name
                ,s.login_name
                ,StartHour                    = RIGHT('0' + CONVERT(varchar(2), DATEPART(HOUR, S.last_request_start_time)),2) +':' + RIGHT('0' + CONVERT(varchar(2), DATEPART(MINUTE, S.last_request_start_time)),2)
                ,percent_complete            = CASE WHEN ROUND(r.percent_complete,0) = 69 THEN CAST(ROUND(r.percent_complete,0) AS VARCHAR) + ' NICE' ELSE R.percent_complete END
                ,CurrentDuration            = DATEDIFF(minute, S.Last_request_start_time, getdate())
                ,s.status
				,r.start_time
				,r.total_elapsed_time
                ,r.status
                ,r.command
                ,r.reads
                ,r.writes
                ,r.logical_reads
                ,sql_text                    = (select text from sys.dm_exec_sql_text(r.sql_handle))
                ,s.deadlock_priority
                ,r.blocking_session_id
        --    SELECT    *
        FROM    sys.dm_exec_sessions s
                INNER JOIN    sys.dm_exec_requests r    ON
                        s.session_id = r.session_id 
        WHERE    host_name IS NOT NULL



