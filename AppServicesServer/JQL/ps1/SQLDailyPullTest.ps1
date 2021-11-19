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
Invoke-Sqlcmd -Query "TRUNCATE TABLE APPLICATIONSERVICES_IM.dbo.AllProdIssueTickets_DailyTest" -ServerInstance PROSHFASDB1
$secpasswd =ConvertTo-SecureString 'igfkp4eylAVWDHaK7pfN32E4' -AsPlainText -Force 
$cred = New-Object System.Management.Automation.PSCredential ("jirabot@shyftanalytics.com", $secpasswd)
set-JiraConfigServer 'https://trinitypharmasolutions.atlassian.net'
$Session=New-JiraSession -Credential $cred


$Query = get-content C:\JQL\JQLDaily.txt|Out-String
$IssueList = Get-JiraIssue -Query $Query

$IssuesInfo = $IssueList|Select-Object  Key,
Project,
Summary,
Status,
@{Name="Client_Facing"; Expression={$_.customfield_10200.value}},
@{Name="Identified_By"; Expression={$_.customfield_10300.value}},
@{Name="Source"; Expression = {$_.customfield_13374.value}},
@{Name="ProdIssueRootCause"; Expression = {$_.customfield_13304.value -join ','}},
@{Name = "TypeofIssue"; Expression = {$_.issuetype.name}},
@{Name = "IssuePriority"; Expression = {$_.priority.name}}, 
Created, 
Updated,
Resolutiondate,
@{Name = "Resolution"; Expression = {$_.resolution.name}},
@{Name="ResolutionSteps"; Expression = {$_.customfield_13318}},
@{Name="IssueDesc"; Expression = {$_.description}},
@{Name="IssueLinks"; Expression = {$_.IssueLinks -join ','}},
@{Name="EscalatedtoTech"; Expression = {$_.customfield_13302.value}}, 
@{Name="RunLate"; Expression = {$_.customfield_13371.value}},
@{Name="SLA"; Expression = {$_.customfield_13303.value}},
@{Name="Vendor"; Expression = {$_.customfield_13384.value}},
Assignee|Out-DataTable


$connectionString = "Data Source=localhost; Integrated Security=True;Initial Catalog=ApplicationServices_IM;"
$bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString
#Define the destination table 
$bulkCopy.DestinationTableName = "AllProdIssueTickets_DailyTest"
#load the data into the target
$bulkCopy.WriteToServer($IssuesInfo)