--change <customer> to customername
USE <customer>_TSK
GO


DECLARE @AuthOUSERID VARCHAR(255)='samlp|greenwich-prod|HGretton@greenwichbiosciences.com'
DECLARE @USERNAME VARCHAR(255)='HGretton@greenwichbiosciences.com'
DECLARE @EMAIL VARCHAR(255)='HGretton@greenwichbiosciences.com'
DECLARE @DISPLAYNAME VARCHAR(255)='Hillary Gretton'
--print @username
--print @email
--print @displayname


------add test user in to tbluser
INSERT INTO [TSK].[tblUser] (AUTH0USERID,USERNAME,EMAIL,DISPLAYNAME,ACTIVE)
VALUES (@AuthOUSERID,@USERNAME,@EMAIL,@DISPLAYNAME,1)

declare @userid varchar(255)
set @userid = (select id from tsk.tbluser where username = @USERNAME)
--print @userid

------insert user role
INSERT INTO TSK.tblUserRole
VALUES (@userid,7)--should be 7 not 2

select * from [TSK].[tblUser] where id = @userid
select * from [TSK].tblUserRole where userid=@userid