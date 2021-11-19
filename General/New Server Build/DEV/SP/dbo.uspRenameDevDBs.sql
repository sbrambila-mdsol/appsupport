USE [TPS_DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspRenameDevDBs]    Script Date: 4/10/2020 1:29:19 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('uspRenameDevDBs','P') IS NOT NULL DROP PROCEDURE [dbo].[uspRenameDevDBs]
GO


CREATE PROCEDURE [dbo].[uspRenameDevDBs] 

--EXEC [uspRenameDevDBs]

AS

SET NOCOUNT ON

DECLARE @SQL VARCHAR(8000)
DECLARE @Customer VARCHAR(255)

SET @Customer=(select [dbo].[udfGetServerSetting]('SQLServerAgentOperator'))

SET @SQL='
USE MASTER ALTER DATABASE AMIDEV Modify Name = '+@Customer+'

USE MASTER ALTER DATABASE AMIDEV_Zubr_IM Modify Name = '+@Customer+'_Zubr_IM

USE MASTER ALTER DATABASE AMIDEV_ADHOC Modify Name = '+@Customer+'_ADHOC

USE MASTER ALTER DATABASE AMIDEV_CM Modify Name = '+@Customer+'_CM

USE MASTER ALTER DATABASE AMIDEV_TSK Modify Name = '+@Customer+'_TSK

USE MASTER ALTER DATABASE AMIDEV_TSK_ADHOC Modify Name = '+@Customer+'_TSK_ADHOC

USE MASTER ALTER DATABASE AMIDEV_TSK_IM Modify Name = '+@Customer+'_TSK_IM

USE MASTER ALTER DATABASE AMIDEV_TSK_RPT Modify Name = '+@Customer+'_TSK_RPT
'
--PRINT @SQL
EXEC(@SQL)
GO


