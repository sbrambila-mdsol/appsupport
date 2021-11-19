-- verify name incorrect
SELECT @@servername;

-- Remove the old name from the SQL server
sp_dropserver 'SQL2017DEV';
go

-- Add the new name, with local set as well.
sp_addserver 'DEVBLP10DB1',LOCAL;
GO


--- restart sql

-- verify change taken
SELECT @@servername;