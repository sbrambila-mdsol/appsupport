if (Get-Module -ListAvailable -Name "JiraPS")
{
	Write-Host "JIRA PS Module is installed"
}
else {
    Write-Host "Installing JIRAPS..."
	Install-Module JiraPS -Scope CurrentUser -Force
}
New-Item -Path ".\LogPath" -ItemType Directory -Force
function Write-Log
{
  param(
    [Parameter(Mandatory)]
    [string]$Message,

    [Parameter()]
    [ValidateSet('1','2','3')]
    [int]$Severity = 1 ## Default to a low severity. Otherwise, override
  )

  $line = [pscustomobject]@{
    'DateTime' = (Get-Date)
    'Message' = $Message
    'Severity' = $Severity
  }

  ## Ensure that $LogFilePath is set to a global variable at the top of script
  $line | Export-Csv -Path $LogFilePath -Append -NoTypeInformation
}
$global:LogFilePath = '.\LogPath\JiraLog.log'
function Get-PublishedModuleVersion
{
   <#
    .SYNOPSIS
    Takes a module name and searches the Powershell gallery for its current version number. It accepts pipeline input for the module name.

    .DESCRIPTION
    When using Get-InstalledModule | Update-Module, this takes a long time. So some smart people on the web thought about how to improve this process.
    The result is impressing - fetching the version number from the Powershell gallery URL for a module is a huge improvement over relying on Update-Module to detect the version numbers on its own.

    .PARAMETER ModuleName
    Specifies a module name to search the current version for

    .EXAMPLE
    Get-PublishedModuleVersion -ModuleName IseSteroids
    Searches for the IseSteroids version in the Powershell gallery and returns its version number.

    .LINK
    http://www.powertheshell.com/findmoduleversion/
    http://scriptingfee.de/isesteroids-auf-aktuellem-stand-halten/

    .INPUTS
    System.String

    .OUTPUTS
    System.Version
  #>

   [ CmdletBinding() ]
   param
   (
     [ Parameter( Position = 0, HelpMessage='A module name must be specified to search for its current version. Please enter the name of a module.', Mandatory = $True, ValueFromPipeline = $True ) ] [string] $ModuleName
   )
   begin {
     $baseurl = 'https://www.powershellgallery.com/packages'
   }
   process {
     # access the main module page, and add a random number to trick proxies
     $url = ( '{0}/{1}/?dummy={2}' -f $baseurl, $ModuleName, ( Get-Random ) )
     $request = [System.Net.WebRequest]::Create( $url )
     # do not allow to redirect. The result is a "MovedPermanently"
     $request.AllowAutoRedirect = $false
     try
     {
       # send the request
       $response = $request.GetResponse()
       # get back the URL of the true destination page, and split off the version
       $response.GetResponseHeader( 'Location' ).Split( '/' )[-1] -as [Version]
       # make sure to clean up
       $response.Close()
       $response.Dispose()
     }
     catch
     {
       Write-Warning -Message $_.Exception.Message
     }
   }
}


Write-Log -Message "Checking for JIRA PS Latest Version"
$LatestVersion=Get-PublishedModuleVersion -ModuleName JiraPS
$JiraVersion=Get-Module -ListAvailable -Name "JiraPS"|Select-Object Version

if ( $JiraVersion.Version -notcontains $LatestVersion) 
{
Update-Module -Name JiraPS -Force
Write-Log -Message "Updated JIRAPS to Latest Version"
}
ELSE {Write-Log -Message "Jira is Up To Date"}

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

Invoke-Sqlcmd -Query "INSERT INTO APPLICATIONSERVICES_IM.dbo.AllProdRunTickets_Full SELECT * FROM APPLICATIONSERVICES_IM.dbo.AllProdRunTickets_Daily TRUNCATE TABLE APPLICATIONSERVICES_IM.dbo.AllProdRunTickets_Daily" -ServerInstance PROSHFASDB1
$Query = get-content C:\JQL\JQLRunDaily.txt|Out-String
$RunList = Get-JiraIssue -Query $Query

$RunsInfo = $RunList|Select-Object  Key,
Project,
Summary,
Status,
Created, 
Updated,
Resolutiondate,
@{Name="Epic"; Expression = {$_.customfield_10008}},
@{Name="IssueFree"; Expression = {$_.customfield_11100.value}},
@{Name="OnTime"; Expression = {$_.customfield_13301.value -join ','}},
@{Name="Source"; Expression = {$_.customfield_13374.value}},
@{Name="HandledBy"; Expression = {$_.customfield_13390.value}},
Assignee|Out-DataTable


$connectionString = "Data Source=localhost; Integrated Security=True;Initial Catalog=ApplicationServices_IM;"
$bulkCopy = new-object ("Data.SqlClient.SqlBulkCopy") $connectionString
#Define the destination table 
$bulkCopy.DestinationTableName = "AllProdRunTickets_Daily"
#load the data into the target
$bulkCopy.WriteToServer($RunsInfo)