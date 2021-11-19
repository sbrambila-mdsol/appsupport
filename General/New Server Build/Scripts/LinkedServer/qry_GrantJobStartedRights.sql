--needs to be run on the processing box

use tps_dba
go

GRANT EXECUTE ON OBJECT::uspCheckIfServerOrJobStarted  
    TO AgileDWorkbenchRestricted