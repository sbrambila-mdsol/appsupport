USE [TPS_DBA]
GO

IF OBJECT_ID('uspRenameLogicalNames','P') IS NOT NULL DROP PROCEDURE [dbo].[uspRenameLogicalNames]
GO


/****** Object:  StoredProcedure [dbo].[uspRenameLogicalNames]    Script Date: 4/10/2020 11:43:22 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspRenameLogicalNames]

--EXEC [uspRenameDevLogicalNames]

AS

SET NOCOUNT ON

DECLARE @SQL VARCHAR(8000)
DECLARE @Customer VARCHAR(255)

SET @Customer=(select [dbo].[udfGetServerSetting]('SQLServerAgentOperator'))

SET @SQL='
ALTER DATABASE '+@Customer+'_ADHOC MODIFY FILE ( NAME = AMI_ADHOC, NEWNAME = '+@Customer+'_ADHOC)
ALTER DATABASE '+@Customer+'_ADHOC MODIFY FILE ( NAME = AMI_ADHOC_Log, NEWNAME = '+@Customer+'_ADHOC_Log)

ALTER DATABASE '+@Customer+'_TSK MODIFY FILE ( NAME = AMI_TSK, NEWNAME = '+@Customer+'_TSK)
ALTER DATABASE '+@Customer+'_TSK MODIFY FILE ( NAME = AMI_TSK_Log, NEWNAME = '+@Customer+'_TSK_Log)

ALTER DATABASE '+@Customer+'_TSK_ADHOC MODIFY FILE ( NAME = AMI_TSK_ADHOC, NEWNAME = '+@Customer+'_TSK_ADHOC)
ALTER DATABASE '+@Customer+'_TSK_ADHOC MODIFY FILE ( NAME = AMI_TSK_ADHOC_Log, NEWNAME = '+@Customer+'_TSK_ADHOC_Log)

ALTER DATABASE '+@Customer+'_TSK_IM MODIFY FILE ( NAME = AMI_TSK_IM, NEWNAME = '+@Customer+'_TSK_IM)
ALTER DATABASE '+@Customer+'_TSK_IM MODIFY FILE ( NAME = AMI_TSK_IM_Log, NEWNAME = '+@Customer+'_TSK_IM_Log)

ALTER DATABASE '+@Customer+'_TSK_RPT MODIFY FILE ( NAME = AMI_TSK_RPT, NEWNAME = '+@Customer+'_TSK_RPT)
ALTER DATABASE '+@Customer+'_TSK_RPT MODIFY FILE ( NAME = AMI_TSK_RPT_Log, NEWNAME = '+@Customer+'_TSK_RPT_Log)'

--PRINT @SQL
EXEC(@SQL)
GO


