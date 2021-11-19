USE [master]
GO

IF EXISTS (select name from sys.server_principals WHERE NAME='LinkedServer')
DROP LOGIN [LinkedServer]

/****** Object:  Login [AgileDWorkbench]    Script Date: 12/17/2018 12:15:07 PM ******/
IF EXISTS (select name from sys.server_principals WHERE NAME='AgileDWorkbench')
DROP LOGIN [AgileDWorkbench]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [AgileDWorkbench]    Script Date: 12/17/2018 12:15:07 PM ******/
CREATE LOGIN [AgileDWorkbench] WITH PASSWORD=N'miqsf*KRqpVb', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

ALTER SERVER ROLE [sysadmin] ADD MEMBER [AgileDWorkbench]
GO

---restricted
IF EXISTS (select name from sys.server_principals WHERE NAME='AgileDWorkbenchRestricted')
DROP LOGIN [AgileDWorkbenchRestricted]
GO

/* For security reasons the login is created disabled and with a random password. */
/****** Object:  Login [AgileDWorkbench]    Script Date: 12/17/2018 12:15:07 PM ******/
CREATE LOGIN [AgileDWorkbenchRestricted] WITH PASSWORD=N'U!tzUFiO!KmM', DEFAULT_DATABASE=[master], DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

EXEC tps_dba.dbo.uspGrantRevokeReadOnlyAccess 'AgileDWorkbenchRestricted','Add'

--DROP OLD SPROC TO ADD LINKEDSERVER
USE TPS_DBA
GO
DROP PROCEDURE [dbo].[uspTPS_AddLinkedUser]


