USE [<Customer>_TSK]
GO

IF OBJECT_ID('uspUpdateCommandCenterRole','P') IS NOT NULL
DROP PROCEDURE [dbo].[uspUpdateCommandCenterRole]
GO

/****** Object:  StoredProcedure [dbo].[uspUpdateCommandCenterRole]    Script Date: 12/17/2019 3:15:36 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspUpdateCommandCenterRole] (
/*******************************************************************************************
Purpose: To update user role id in Command Center	
Inputs:		
Author:	Todd Forman	
Created: 12/17/2019	
Copyright:	
RunTime:	
Execution:	
					EXEC dbo.uspUpdateCommandCenterRole 'flin@<Customer>.com','3'
 
Helpful Selects:

					---- Source Tables:
						SELECT * FROM [<Customer>_TSK].[TSK].[tblUser]
						SELECT * FROM [<Customer>_TSK].[TSK].[tblUserRole]
					
					---- Staging Tables:
						SELECT * FROM 

					---- Reporting Tables:
						SELECT * FROM 
						



*******************************************************************************************/
@Username VARCHAR(255),
@RoleID INT)

AS
UPDATE R
SET RoleId=@RoleID
FROM [<Customer>_TSK].[TSK].[tblUser] as t
	INNER JOIN [<Customer>_TSK].[TSK].[tblUserRole] as r on t.Id=r.UserId
WHERE UserName=@Username
GO


