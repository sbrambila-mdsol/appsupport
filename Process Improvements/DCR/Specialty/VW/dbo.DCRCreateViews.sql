USE [VERASTEM]
GO


if exists(select 1 from sys.views where name='vwOutbound_Veeva_SpecialtyDCRUpdate' and type='v')
DROP VIEW [dbo].[vwOutbound_Veeva_SpecialtyDCRUpdate]
GO


SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


create view [dbo].[vwOutbound_Veeva_DCRUpdate]

as

select Id,Specialty_1_vod__c from VERASTEM.DBO.tblstgVeevaDataChangeRequest where Valid=1
GO


