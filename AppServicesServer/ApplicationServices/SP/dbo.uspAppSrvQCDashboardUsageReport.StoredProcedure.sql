USE [ApplicationServices]
GO
/****** Object:  StoredProcedure [dbo].[uspAppSrvQCDashboardUsageReport]    Script Date: 4/13/2020 3:11:13 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspAppSrvQCDashboardUsageReport]  

AS
BEGIN
	SET NOCOUNT ON 
	-----------
	--Logging
	-----------	
	DECLARE @tblDataRunLog AS AGD.typDataRunLog
	INSERT INTO @tblDataRunLog  
	SELECT * FROM AGD.udfGetDataRunLogTable (2, @@PROCID,null) ---The 2 is the TPSExecProcesTypeId which represents logging for store procedure
	
	BEGIN TRY

		------------
		--Declare variables
		-----------
		DECLARE   
				@vchXMLUsage varchar(MAX)
				,@vchXMLTop varchar(MAX)
				,@vchXMLTableHeader varchar(MAX)				
				,@vchXML VARCHAR(MAX) 
 

			---------
			--Top Part of XML
			--------	
				SET @vchXMLTop = '
									<html>
									<body>
									';				

			---Table Headers---		
				SET @vchXMLTableHeader = '	<br>								
									<H3>||HEADER||</H3> 
									<table border = 1 style=''padding: 5px''> 
									<tr>
										<th> Week Beginning </th> 
										<th> Report </th> 
										<th> Sunday </th> 
										<th> Monday </th> 
										<th> Tuesday </th> 
										<th> Wednesday </th>
										<th> Thursday </th> 
										<th> Friday </th>
										<th> Saturday </th>
									</tr>	
								';

		 
		-------------
		---Usage ---
		-------------		
		SELECT 
			[Week_Beginning]
			,[ReportName]
			,[Sunday]
			,[Monday]
			,[Tuesday]
			,[Wednesday]
			,[Thursday]
			,[Friday]
			,[Saturday]
		INTO #Results
		FROM [vwQCDashboardDailyUsageReport]		
		ORDER BY [Week_Beginning] ASC, ReportName DESC 							
				
		SELECT @vchXMLUsage  = ISNULL((
									SELECT CASE WHEN (ROW_NUMBER() OVER (ORDER BY [Week_Beginning] ASC, [ReportName] DESC ))%2=0 THEN 'EVEN' ELSE 'ODD' END AS 'td'
									, ''
									, [Week_Beginning] AS 'td'
									, ''
									, [ReportName] AS 'td'
									, ''
									, [Sunday] AS 'td'
									, ''
									, [Monday]  AS 'td'
									, ''
									, [Tuesday] AS 'td' 
									, ''
									, [Wednesday] AS 'td' 															
									, ''
									, [Thursday] AS 'td' 					
									, ''
									, [Friday] AS 'td'
									, ''	
									, [Saturday] AS 'td'
									, ''							 					 
									FROM #Results 
									FOR XML PATH('tr'), ELEMENTS
								  ), '') + ' </table>';				
		
		
		----------
		---Concatenation
		----------
		SET @vchXML = ISNULL(@vchXMLTop, '')  
		+ REPLACE(@vchXMLTableHeader, '||HEADER||', 'AQC Report Usage::')		+	ISNULL(@vchXMLUsage, '') ;
		
		-----------
		--Styling--
		-----------
		SET @vchXML = REPLACE(@vchXML, '<tr><td>ODD</td>','<tr style="background-color:gainsboro">');
		SET @vchXML = REPLACE(@vchXML,'<tr><td>EVEN</td>','<tr>');	


        EXEC msdb.dbo.sp_send_dbmail @recipients = 'shyftapplicationservices@medidata.com',
                @subject = 'AQC Dashboard Usage',
                @body = @vchXML,
                @body_format = 'HTML' ;
	
 
		DROP TABLE #Results;
		
	END TRY
	
	BEGIN CATCH
		   
		UPDATE @tblDataRunLog 
		SET ErrorMessage=ERROR_MESSAGE() 
		  , ErrorNumber =ERROR_NUMBER()	
		
	END CATCH
			   		   
		EXEC AGD.uspInsertDataRunLog  @tblDataRunLog, 1 -----AGD.uspInsertDataRunLog will raise error if there was an error

END


GO
