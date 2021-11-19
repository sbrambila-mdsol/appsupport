if (Get-Module -ListAvailable -Name "JiraPS")
{
	Write-Host "JIRA PS Module is installed"
}
else {
    Write-Host "Installing JIRAPS..."
	Install-Module JiraPS -Scope CurrentUser -Force
}
Import-Module JiraPS 
Function Out-DataTable {
    $dt = new-object Data.datatable  
    $First = $true  
 
    foreach ($item in $input) {  
        $DR = $DT.NewRow()  
        $Item.PsObject.get_properties() | foreach {  
            if ($first) {  
                $Col = new-object Data.DataColumn  
                $Col.ColumnName = $_.Name.ToString()  
                $DT.Columns.Add($Col)       
            }  
            if ($_.value -eq $null) {  
                $DR.Item($_.Name) = "[empty]"  
            }  
            elseif ($_.IsArray) {  
                $DR.Item($_.Name) = [string]::Join($_.value , ";")  
            }  
            else {  
                $DR.Item($_.Name) = $_.value  
            }  
        }  
        $DT.Rows.Add($DR)  
        $First = $false  
    } 
 
    return @(, ($dt))
 
}
$secpasswd =ConvertTo-SecureString 'igfkp4eylAVWDHaK7pfN32E4' -AsPlainText -Force 
$cred = New-Object System.Management.Automation.PSCredential ("jirabot@shyftanalytics.com", $secpasswd)
set-JiraConfigServer 'https://trinitypharmasolutions.atlassian.net'
$Session=New-JiraSession -Credential $cred

Invoke-Sqlcmd -Query "TRUNCATE TABLE APPLICATIONSERVICES_IM.dbo.AllProdStoryTickets_FULL" -ServerInstance PROSHFASDB1
$Query = get-content C:\JQL\JQLStory.txt|Out-String
$RunList = Get-JiraIssue -Query $Query

$RunsInfo = $RunList|Select-Object  Key,
Project,
Summary,
Status,
Created, 
Updated,
Resolutiondate,
@{Name = "Priority"; Expression = {$_.priority.name}},
@{Name="StoryType"; Expression = {$_.customfield_13300.value}},
@{Name="StoryPts"; Expression = {$_.customfield_10004}},
@{Name = "Sprint"; Expression = {$_.customfield_10007.name}},
@{Name = "SprintStartDt"; Expression = {$_.customfield_10007.startdate}},
@{Name = "SprintEndDt"; Expression = {$_.customfield_10007.enddate}},
@{Name="IdentifiedBy"; Expression = {$_.customfield_10300.value}},
@{Name="ClientFacing"; Expression = {$_.customfield_10200.value}},
Reporter,
Assignee|Out-DataTable


$connectionString = "Data Source=localhost; Integrated Security=True;Initial Catalog=ApplicationServices_IM;"
$bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString
#Define the destination table 
$bulkCopy.DestinationTableName = "AllProdStoryTickets_FULL"
#load the data into the target
$bulkCopy.WriteToServer($RunsInfo)