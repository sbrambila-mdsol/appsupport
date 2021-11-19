CREATE PROCEDURE uspAddCustomertoQADash (@CustomerName varchar(255),@CustSchema varchar(5))

AS

--exec uspAddCustomertoQADash ,'COH', 'COHERUS'

USE [ApplicationServices]
GO

DECLARE @RC int
DECLARE @CustSchema varchar(50)
DECLARE @CustomerName varchar(100)


-- TODO: Set parameter values here.
EXECUTE @RC = [dbo].[uspAddCustomerToQAdashboard]
   @CustSchema
  ,@CustomerName
GO