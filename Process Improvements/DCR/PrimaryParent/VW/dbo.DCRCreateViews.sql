USE <Customer>--[VERASTEM]
GO

/****** Object:  View [dbo].[vwOutbound_Veeva_DCRUpdate]    Script Date: 10/15/2019 8:51:26 AM ******/
if exists(select 1 from sys.views where name='vwOutbound_Veeva_DCRUpdate' and type='v')
DROP VIEW [dbo].[vwOutbound_Veeva_DCRUpdate]
GO

/****** Object:  View [dbo].[vwOutbound_Veeva_DCRLineUpdate]    Script Date: 10/15/2019 8:51:26 AM ******/
if exists(select 1 from sys.views where name='vwOutbound_Veeva_DCRLineUpdate' and type='v')
DROP VIEW [dbo].[vwOutbound_Veeva_DCRLineUpdate]
GO

/****** Object:  View [dbo].[vwOutbound_Veeva_DCRAccountUpdate]    Script Date: 10/15/2019 8:51:26 AM ******/
if exists(select 1 from sys.views where name='vwOutbound_Veeva_DCRAccountUpdate' and type='v')
DROP VIEW [dbo].[vwOutbound_Veeva_DCRAccountUpdate]
GO

/****** Object:  View [dbo].[vwOutbound_Veeva_DCRAccountUpdate]    Script Date: 10/15/2019 8:51:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vwOutbound_Veeva_DCRAccountUpdate]

as

select Id,PRIMARY_PARENT_VOD__C from <customer>.DBO.tblstgVeevaAccountDCR where Valid=1


GO

/****** Object:  View [dbo].[vwOutbound_Veeva_DCRLineUpdate]    Script Date: 10/15/2019 8:51:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vwOutbound_Veeva_DCRLineUpdate]

as

select Id,resolution_note_vod__c,Result_vod__c from <customer>.DBO.tblstgVeevaDataChangeRequestLine where Valid=1


GO

/****** Object:  View [dbo].[vwOutbound_Veeva_DCRUpdate]    Script Date: 10/15/2019 8:51:26 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vwOutbound_Veeva_DCRUpdate]

as

select Id,Notes_vod__c,resolution_note_vod__c,result_vod__c,Status_vod__c from <customer>.DBO.tblstgVeevaDataChangeRequest where Valid=1
GO


