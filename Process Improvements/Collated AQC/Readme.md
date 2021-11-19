1. Open VW folder and replace <customer> in all views with the appropriate customer name and execute them.
2. Open SCM folder and replace customerabbr with customer schema and execute script.
3. Open TBL folder and replace <schema> with customer schema in all scripts and execute them.
4. Open SP folder and execute passing in the appropriate CustSchema and CustomerName.
5. Open StrataLogs\refresh scripts folder and create a new customer batch file (you can use any existing customer batch file as a template). Check in and merged by manager.
6. Ask Sunny to schedule the new customer batch file to run on AWS workspace every 5 minutes.

