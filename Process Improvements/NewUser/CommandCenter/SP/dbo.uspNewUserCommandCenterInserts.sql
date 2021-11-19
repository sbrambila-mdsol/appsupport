USE [<Customer>_TSK]
GO

IF OBJECT_ID('uspNewUserCommandCenterInserts','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspNewUserCommandCenterInserts]
GO

/****** Object:  StoredProcedure [dbo].[uspNewUserCommandCenterInserts]    Script Date: 11/14/2019 9:43:05 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspNewUserCommandCenterInserts]
/*******************************************************************************************
Purpose: To Add New Users to Command Center TSK tables		
Inputs:	Veeva	
Author:	Todd Forman	
Created: 11/13/2019	
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspNewUserCommandCenterInserts
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM [<Customer>_TSK_IM].[dbo].[tbldf_CommandCenterUsers]
						SELECT * FROM [TSK].[tblUser]
						SELECT * FROM [TSK].[tblUserRole]
					
					---- Staging Tables:
				

					---- Reporting Tables:
						SELECT * FROM [TSK].[tblUser]
						SELECT * FROM [TSK].[tblUserRole]
						



*******************************************************************************************/
AS

CREATE TABLE #newuser (ID INT IDENTITY(1,1),Authid VARCHAR(255),Email VARCHAR(255),Roleid INT,DisplayName VARCHAR(255))

--WILL GET POPULATED FROM SPREADSHEET DATAFEED
INSERT INTO #newuser (Authid,Email,Roleid,DisplayName)
--values ('auth0|5b50da0df7ac1b2c6128365e','TForman@shyftanalytics.com','1','Todd Forman')
SELECT AuthID,Email,RoleID,DisplayName
FROM [<Customer>_TSK_IM].[dbo].[tbldf_CommandCenterUsers]--change for appropriate customer

DECLARE @ID INT
DECLARE @Email varchar(255)

SET @ID=(SELECT MIN(ID) FROM #newuser)

--ADD USER
WHILE @ID <= (SELECT MAX(ID) FROM #newuser)
BEGIN
	SET @Email=(SELECT EMAIL FROM #newuser WHERE ID=@ID)
	IF NOT EXISTS (SELECT id from TSK.tblUser WHERE Email=@Email)
	BEGIN
		INSERT INTO [TSK].[tblUser](Auth0UserID,UserName,Email,DisplayName,Active)
		SELECT Authid,Email,Email,DisplayName,1
		FROM #newuser
		WHERE ID=@ID
	END

	--ADD USERROLE
	IF NOT EXISTS (SELECT UserId FROM TSK.tblUserRole WHERE UserId in (SELECT id FROM TSK.tblUser WHERE Email=@Email))
	BEGIN
	DECLARE @userid INT
	SET @userid=(SELECT id FROM TSK.tblUser WHERE Email=@Email)
		INSERT INTO [TSK].[tblUserRole]
		SELECT @userid,Roleid
		FROM #newuser
		WHERE ID = @ID
	END
	SET @ID=@ID+1
END
GO


