@echo off
for /r %%i in (*.sql) do (
if not %%~nxi == Aggregate.sql (
type "%%i" >> Aggregate.sql
echo. >> Aggregate.sql
echo. >> Aggregate.sql
echo GO >> Aggregate.sql
)
)