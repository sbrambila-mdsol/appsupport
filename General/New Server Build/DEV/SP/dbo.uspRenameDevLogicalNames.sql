USE [TPS_DBA]
GO

/****** Object:  StoredProcedure [dbo].[uspRenameDevLogicalNames]    Script Date: 4/10/2020 1:31:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF OBJECT_ID('uspRenameDevLogicalNames','P') IS NOT NULL DROP PROCEDURE [dbo].[uspRenameDevLogicalNames]
GO

CREATE PROCEDURE [dbo].[uspRenameDevLogicalNames]

--EXEC [uspRenameDevLogicalNames]

AS

SET NOCOUNT ON

DECLARE @SQL VARCHAR(8000)
DECLARE @Customer VARCHAR(255)

SET @Customer=(select [dbo].[udfGetServerSetting]('SQLServerAgentOperator'))

SET @SQL='
ALTER DATABASE '+@Customer+' MODIFY FILE ( NAME = AMIDEV, NEWNAME = '+@Customer+')
ALTER DATABASE '+@Customer+' MODIFY FILE ( NAME = AMIDEV_Log, NEWNAME = '+@Customer+'_Log)

ALTER DATABASE '+@Customer+'_ADHOC MODIFY FILE ( NAME = AMIDEV_ADHOC, NEWNAME = '+@Customer+'_ADHOC)
ALTER DATABASE '+@Customer+'_ADHOC MODIFY FILE ( NAME = AMIDEV_ADHOC_Log, NEWNAME = '+@Customer+'_ADHOC_Log)

ALTER DATABASE '+@Customer+'_CM MODIFY FILE ( NAME = AMIDEV_CM, NEWNAME = '+@Customer+'_CM)
ALTER DATABASE '+@Customer+'_CM MODIFY FILE ( NAME = AMIDEV_CM_Log, NEWNAME = '+@Customer+'_CM_Log)

ALTER DATABASE '+@Customer+'_Zubr_IM MODIFY FILE ( NAME = AMIDEV_Zubr_IM, NEWNAME = '+@Customer+'_Zubr_IM)
ALTER DATABASE '+@Customer+'_Zubr_IM MODIFY FILE ( NAME = AMIDEV_Zubr_IM_Log, NEWNAME = '+@Customer+'_Zubr_IM_Log)

ALTER DATABASE '+@Customer+'_TSK MODIFY FILE ( NAME = AMIDEV_TSK, NEWNAME = '+@Customer+'_TSK)
ALTER DATABASE '+@Customer+'_TSK MODIFY FILE ( NAME = AMIDEV_TSK_Log, NEWNAME = '+@Customer+'_TSK_Log)

ALTER DATABASE '+@Customer+'_TSK_ADHOC MODIFY FILE ( NAME = AMIDEV_TSK_ADHOC, NEWNAME = '+@Customer+'_TSK_ADHOC)
ALTER DATABASE '+@Customer+'_TSK_ADHOC MODIFY FILE ( NAME = AMIDEV_TSK_ADHOC_Log, NEWNAME = '+@Customer+'_TSK_ADHOC_Log)

ALTER DATABASE '+@Customer+'_TSK_IM MODIFY FILE ( NAME = AMIDEV_TSK_IM, NEWNAME = '+@Customer+'_TSK_IM)
ALTER DATABASE '+@Customer+'_TSK_IM MODIFY FILE ( NAME = AMIDEV_TSK_IM_Log, NEWNAME = '+@Customer+'_TSK_IM_Log)

ALTER DATABASE '+@Customer+'_TSK_RPT MODIFY FILE ( NAME = AMIDEV_TSK_RPT, NEWNAME = '+@Customer+'_TSK_RPT)
ALTER DATABASE '+@Customer+'_TSK_RPT MODIFY FILE ( NAME = AMIDEV_TSK_RPT_Log, NEWNAME = '+@Customer+'_TSK_RPT_Log)'

--PRINT @SQL
EXEC(@SQL)
GO


