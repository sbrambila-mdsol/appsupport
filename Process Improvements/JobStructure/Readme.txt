1. Make sure uspSendFailNotification is installed from appsupport\Process Improvements\PagerDuty\SP.
2. Execute script in SP folder called uspJobProcessingCleanup.
3. In job folder open script and replace service account and operator @owner_login_name=N'TPSINTERNAL\<servicaccount>', @notify_email_operator_name=N'<operator>'.
4. Save the job script file and execute it.


