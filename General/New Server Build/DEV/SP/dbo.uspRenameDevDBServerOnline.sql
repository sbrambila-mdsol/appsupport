USE [TPS_DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspRenameDevDBServerOnline]    Script Date: 4/10/2020 1:30:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('uspRenameDevDBServerOnline','P') IS NOT NULL DROP PROCEDURE [dbo].[uspRenameDevDBServerOnline]
GO

CREATE PROCEDURE [dbo].[uspRenameDevDBServerOnline] 

--EXEC uspRenameDevDBServerOnline 

AS

SET NOCOUNT ON

DECLARE @SQL VARCHAR(8000)
DECLARE @Customer VARCHAR(255)

SET @Customer=(select [dbo].[udfGetServerSetting]('SQLServerAgentOperator'))

SET @SQL='
USE MASTER ALTER DATABASE '+@Customer+' SET ONLINE
USE MASTER ALTER DATABASE '+@Customer+' SET MULTI_USER

USE MASTER ALTER DATABASE '+@Customer+'_Zubr_IM SET ONLINE
USE MASTER ALTER DATABASE '+@Customer+'_Zubr_IM SET MULTI_USER

USE MASTER ALTER DATABASE '+@Customer+'_ADHOC SET ONLINE
USE MASTER ALTER DATABASE '+@Customer+'_ADHOC SET MULTI_USER

USE MASTER ALTER DATABASE '+@Customer+'_CM SET ONLINE
USE MASTER ALTER DATABASE '+@Customer+'_CM SET MULTI_USER

USE MASTER ALTER DATABASE '+@Customer+'_TSK SET ONLINE
USE MASTER ALTER DATABASE '+@Customer+'_TSK SET MULTI_USER

USE MASTER ALTER DATABASE '+@Customer+'_TSK_ADHOC SET ONLINE
USE MASTER ALTER DATABASE '+@Customer+'_TSK_ADHOC SET MULTI_USER

USE MASTER ALTER DATABASE '+@Customer+'_TSK_IM SET ONLINE
USE MASTER ALTER DATABASE '+@Customer+'_TSK_IM SET MULTI_USER

USE MASTER ALTER DATABASE '+@Customer+'_TSK_RPT SET ONLINE
USE MASTER ALTER DATABASE '+@Customer+'_TSK_RPT SET MULTI_USER

'
--PRINT @SQL
EXEC(@SQL)
GO


