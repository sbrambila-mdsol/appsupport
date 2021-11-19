USE TPS_DBA
GO

IF EXISTS (SELECT 1 FROM SYS.TABLES WHERE NAME ='tblRunTickets') DROP TABLE dbo.tblRunTickets 
GO

/****** Object:  Table [dbo].[ProductionRunTicketsFinal]    Script Date: 7/11/2019 1:11:09 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].tblRunTickets(
	[Project] [varchar](50) NULL,
	[Issue Type] [varchar](50) NULL,
	[Summary] [varchar](500) NULL,
	[Assignee] [varchar](50) NULL,
	[Epic Link] [varchar](50) NULL,
	[Custom field (Issue-Free Run)] [varchar](50) NULL,
	[Custom Field (On Time Delivery)] [varchar](50) NULL,
	[ActiveTicket] [varchar](50) NULL,
	[Active] bit NULL
) ON [PRIMARY]
GO

--change projectid and assignee to what you need
DECLARE @Customer varchar(255) = '<CustomerName>'--'Greenwich EU'
DECLARE @ProjectCode varchar(5)= '<PROJECTD>'--'GE'
DECLARE @Assignee varchar(255) = '<Assignee>'--'harrisonsouthworth'


INSERT INTO TPS_DBA.dbo.tblRunTickets  (Project, [Issue Type], Summary, Assignee, [Epic Link], [Custom field (Issue-Free Run)], [Custom Field (On Time Delivery)], ActiveTicket, Active) 
VALUES (@ProjectCode, 'Production Run', 'Monday '+ @Customer+ ' Daily + Weekly Runs', @Assignee, 'CSP-1', 'Yes', 'Yes', NULL, 1)

INSERT INTO TPS_DBA.dbo.tblRunTickets  (Project, [Issue Type], Summary, Assignee, [Epic Link], [Custom field (Issue-Free Run)], [Custom Field (On Time Delivery)], ActiveTicket, Active) 
VALUES (@ProjectCode, 'Production Run', 'Tuesday '+ @Customer+ ' Daily + Weekly Runs', @Assignee, 'CSP-2', 'Yes', 'Yes', NULL, 1)

INSERT INTO TPS_DBA.dbo.tblRunTickets  (Project, [Issue Type], Summary, Assignee, [Epic Link], [Custom field (Issue-Free Run)], [Custom Field (On Time Delivery)], ActiveTicket, Active) 
VALUES (@ProjectCode, 'Production Run', 'Wednesday '+ @Customer+ ' Daily + Weekly Runs', @Assignee, 'CSP-3', 'Yes', 'Yes', NULL, 1)

INSERT INTO TPS_DBA.dbo.tblRunTickets  (Project, [Issue Type], Summary, Assignee, [Epic Link], [Custom field (Issue-Free Run)], [Custom Field (On Time Delivery)], ActiveTicket, Active) 
VALUES (@ProjectCode, 'Production Run', 'Thursday '+ @Customer+ ' Daily + Weekly Runs', @Assignee, 'CSP-4', 'Yes', 'Yes', NULL, 1)

INSERT INTO TPS_DBA.dbo.tblRunTickets  (Project, [Issue Type], Summary, Assignee, [Epic Link], [Custom field (Issue-Free Run)], [Custom Field (On Time Delivery)], ActiveTicket, Active) 
VALUES (@ProjectCode, 'Production Run', 'Friday '+ @Customer+ ' Daily + Weekly Runs', @Assignee, 'CSP-5', 'Yes', 'Yes', NULL, 1)

INSERT INTO TPS_DBA.dbo.tblRunTickets  (Project, [Issue Type], Summary, Assignee, [Epic Link], [Custom field (Issue-Free Run)], [Custom Field (On Time Delivery)], ActiveTicket, Active) 
VALUES (@ProjectCode, 'Production Run', 'Saturday '+ @Customer+ ' Daily + Weekly Runs', @Assignee, 'CSP-12', 'Yes', 'Yes', NULL, 1)

INSERT INTO TPS_DBA.dbo.tblRunTickets  (Project, [Issue Type], Summary, Assignee, [Epic Link], [Custom field (Issue-Free Run)], [Custom Field (On Time Delivery)], ActiveTicket, Active) 
VALUES (@ProjectCode, 'Production Run', 'Sunday '+ @Customer+ ' Daily + Weekly Runs', @Assignee, 'CSP-13', 'Yes', 'Yes', NULL, 1)

select * from dbo.tblRunTickets