1. Create \\<proservername>\c$\PowershellScripts directory on the Processing Server.
2. Copy AutoRunTickets.ps1 to \\<proservername>\c$\PowershellScripts directory
3. Run script JOB Util Production Run Ticket Creation.sql on <proservername>
4. Run script dbo.tblRunTickets to create and populate TPS_DBA.dbo.tblRunTickets on the Processing Server. You will need to create a new set of inserts for the new customer.
5. Run script dbo.ActiveRunTicketSetting on the Processing Server to ensure ActiveRunTicket setting is setup in tps_dba server setting table. 