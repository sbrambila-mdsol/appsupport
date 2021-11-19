USE [VERASTEM]
GO

/****** Object:  View [dbo].[vwOutbound_Veeva_DCRCredentialUpdate]    Script Date: 12/05/2019 3:51:26 PM ******/
if exists(select 1 from sys.views where name='vwOutbound_Veeva_DCRCredentialUpdate' and type='v')
DROP VIEW [dbo].[vwOutbound_Veeva_DCRCredentialUpdate]
GO

/****** Object:  View [dbo].[vwOutbound_Veeva_DCRCredentialUpdate]    Script Date: 12/05/2019 3:51:26 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view [dbo].[vwOutbound_Veeva_DCRCredentialUpdate]

as

select Id,Credential_VOD__C from VERASTEM.DBO.tblstgVeevaCredentialDCR where Valid=1


GO
