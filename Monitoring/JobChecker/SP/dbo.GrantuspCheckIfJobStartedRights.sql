--grant rights
USE tps_dba;   
GRANT EXECUTE ON OBJECT::dbo.uspCheckIfJobStarted
    TO AgileDWorkbenchRestricted;  
GO  

