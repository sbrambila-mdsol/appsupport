USE [TPS_DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspRenameDBs]    Script Date: 4/10/2020 11:38:40 AM ******/
IF OBJECT_ID('uspRenameDBs','P') IS NOT NULL DROP PROCEDURE [dbo].[uspRenameDBs]
GO

/****** Object:  StoredProcedure [dbo].[uspRenameDBs]    Script Date: 4/10/2020 11:38:40 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspRenameDBs] 

--EXEC [uspRenameDevDBs]

AS

SET NOCOUNT ON

DECLARE @SQL VARCHAR(8000)
DECLARE @Customer VARCHAR(255)

SET @Customer=(select [dbo].[udfGetServerSetting]('SQLServerAgentOperator'))

SET @SQL='
USE MASTER ALTER DATABASE AMI_ADHOC Modify Name = '+@Customer+'_ADHOC

USE MASTER ALTER DATABASE AMI_TSK Modify Name = '+@Customer+'_TSK

USE MASTER ALTER DATABASE AMI_TSK_ADHOC Modify Name = '+@Customer+'_TSK_ADHOC

USE MASTER ALTER DATABASE AMI_TSK_IM Modify Name = '+@Customer+'_TSK_IM

USE MASTER ALTER DATABASE AMI_TSK_RPT Modify Name = '+@Customer+'_TSK_RPT
'
--PRINT @SQL
EXEC(@SQL)
GO


