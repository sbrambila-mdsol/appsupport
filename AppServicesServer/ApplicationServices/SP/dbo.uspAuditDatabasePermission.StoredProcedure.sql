USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspAuditDatabasePermission]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspAuditDatabasePermission]
/*******************************************************************************************
Purpose:			Loops through prod and processing servers to log DB permissioning
Inputs:				
Author:				Crichton
Created:			5/16/2018
Copyright:

Execution:			EXEC uspAuditDatabasePermission

History:			


*******************************************************************************************/
AS
BEGIN
	IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE Table_Name='tmpInstance')
	BEGIN
		DROP TABLE tmpInstance
	END

	SELECT InstanceId,LinkedServerName,Row_number () OVER (ORDER BY instanceid) as RowNo    
	INTO   tmpInstance
	FROM   CustomerInstance
	WHERE LinkedServerName IS NOT NULL

	--SELECT * FROM tmpInstance

	DECLARE @Counter INT = (SELECT MAX(RowNo) FROM tmpInstance)

	WHILE @Counter>0
	BEGIN
		DECLARE @InstanceId INT
		DECLARE @LinkedServerName VARCHAR(100)
		DECLARE @Today DATE = (SELECT getdate() )
	
		SELECT	@InstanceId=InstanceId,
				@LinkedServerName=LinkedServerName
		FROM	tmpInstance
		WHERE	RowNo=@Counter and LinkedServerName IS NOT NULL
		--PRINT 'InstanceId: '+CONVERT(VARCHAR(5),@InstanceId)	
		--PRINT 'LinkedServerName: '+@LinkedServerName	
		DECLARE @CanConnect BIT = 0
		BEGIN TRY
			--DECLARE @LinkedServer sysname = CAST ('[' + @LinkedServerName + ']' AS sysname)
			DECLARE @LinkedServer sysname = CAST (@LinkedServerName AS sysname)
			EXEC sp_testlinkedserver @LinkedServer
			SET @CanConnect = 1
		END TRY
		BEGIN CATCH
			INSERT INTO CustomerInstanceAuditError(	InstanceId ,AuditDate ,ErrorMessage)
			SELECT		@InstanceId,@Today,ERROR_MESSAGE()

			SET @CanConnect = 0
		END CATCH
		IF(@CanConnect = 1)
		BEGIN
		
			EXEC uspLoadInstanceDatabasePermissions @InstanceId,@LinkedServerName,@Today
		END
		SET @Counter=@Counter-1
	END
END
GO
