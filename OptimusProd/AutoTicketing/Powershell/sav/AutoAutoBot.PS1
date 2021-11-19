#Load Required Info
#Author: Sam Bloch
#Please denote all Changes at the header of this file! (Ticket Numbers)
[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"
$ErrorActionPreference = "Stop"
New-Item -Path ".\OptimusProdLogs" -ItemType Directory -Force
if (Get-Module -ListAvailable -Name "JiraPS")
{
  'JIRA PS Module is installed'
}
else {
  Install-Module JiraPS -Scope CurrentUser -Force
}
if (Get-Module -ListAvailable -Name "SqlServer")
{
  'SqlServer Module is installed'
}
else {
  Install-Module SqlServer -Scope CurrentUser -Force -AllowClobber
}

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
$global:LogFilePath = '.\OptimusProdLogs\AutoBotLog.log'
Write-Log -Message "JIRA AutoBot Starting"
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
Import-Module SqlServer



try {
  New-Item -Path ".\OptimusProdLogs" -ItemType Directory -Force
  #Copy-Item -Path ".\Servers.csv" -Destination "D:\Servers\"
  Write-Log -Message "Created Directory for Logging"
}
catch { Write-Log -Message $_.Exception.Message -Severity 3
		
		$payload = @{
			"channel" = "#prod_bot"
			"icon_emoji" = ":autobot:" 
			"text" = "*Production Issue Ticket Failed to be created on $localServer*"
			"username" = "Optimus Prod"
			"color"="green"
		}
		Invoke-WebRequest `
			-Body (ConvertTo-Json -Compress -InputObject $payload) `
			-Method Post `
			-Uri 'https://hooks.slack.com/services/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' | Out-Null
	
  break }


#Dropdown Pulls
$localServer = [System.Net.Dns]::GetHostName()
$ProductionServer = [System.Net.Dns]::GetHostName()
$SqlProjectName=invoke-sqlcmd -query "select settingvalue from tps_dba.dbo.tblserversetting where settingname like 'clientname'"-ServerInstance localhost #$PickaServer
$ProjTitleName = $SqlProjectName.Settingvalue
$FindRep = invoke-sqlcmd -query "select settingvalue from tps_dba.dbo.tblserversetting where settingname like 'IssueTicketAssignee'"-ServerInstance localhost #$PickaServer"JiraBot"	
$Rep = 	$FindRep.Settingvalue
$SQLProjname=invoke-sqlcmd -query "Select SettingValue from TPS_DBA.dbo.tblserversetting where settingname='JiraProjectName'"-ServerInstance localhost #$PickaServer
$Projname = $SQLProjname.SettingValue
$SQLChannel=invoke-sqlcmd -query "Select SettingValue from TPS_DBA.dbo.tblserversetting where settingname='SlackFailChannel'"-ServerInstance localhost #$PickaServer
$Channel = $SQLChannel.SlackChannel

Invoke-Sqlcmd -Query "EXEC TPS_DBA.dbo.uspFindLatestErrorInfo" -ServerInstance localhost 

  #Job Failure SQL
  try {
    Write-Log -Message "Query Job Information for $localServer"
    $cmd = Invoke-Sqlcmd -Query "SELECT * FROM TPS_DBA.dbo.tblJobFailure" -ServerInstance localhost  -ErrorAction Stop }
  catch { Write-Log -Message $_.Exception.Message -Severity 3
		
		$payload = @{
			"channel" = "#prod_bot"
			"icon_emoji" = ":autobot:" 
			"text" = "*Production Issue Ticket Failed to be created on $localServer*"
			"username" = "Optimus Prod"
			"color"="green"
		}
		Invoke-WebRequest `
			-Body (ConvertTo-Json -Compress -InputObject $payload) `
			-Method Post `
			-Uri 'https://hooks.slack.com/services/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' | Out-Null
	
    break }
  try {
    Write-Log -Message "Query Error Information for $localServer"
    #Task Failure SQL
    $tblTaskError = Invoke-Sqlcmd -Query "SELECT DISTINCT * FROM TPS_DBA.dbo.tblLatestErrorInfo" -ServerInstance localhost #$PickaServer
  }
  catch { Write-Log -Message $_.Exception.Message -Severity 3
		
		$payload = @{
			"channel" = "#prod_bot"
			"icon_emoji" = ":autobot:" 
			"text" = "*Production Issue Ticket Failed to be created on $localServer*"
			"username" = "Optimus Prod"
			"color"="green"
		}
		Invoke-WebRequest `
			-Body (ConvertTo-Json -Compress -InputObject $payload) `
			-Method Post `
			-Uri 'https://hooks.slack.com/services/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' | Out-Null
	
    break }
  $JobHasMessage = $cmd.Name
  $NoJob = if ($JobHasMessage -eq [System.DBNull]::Value) { "Job Independent Error" } else { $JobHasMessage }

  $FirstDB = $tblTaskError.DB | Select-Object -First 1
  
  $FirstScenario = $tblTaskError.Scenario | Select-Object -First 1
  $FirstDFId = $tblTaskError.DFid | Select-Object -First 1
  $FirstSP = $tblTaskError.SP | Select-Object -First 1
  $TblError=$tblTaskError.Error -join "`r`n`n* "|Out-String
  #$AdditionalError=$tblTaskError.AdditionalError -split ';|;' | -join "`r`n`n* "|Out-String


  #$cmd.name
  #$cmd.step_name
  #$cmd.message
  #$cmd.run_date
  #$cmd.run_time
  #$Labels=@()
  Write-Log -Message "Formatting JIRA Ticket"
  #JIRA Formats
  $Title = '' + $ProjTitleName + ' - ' + $NoJob + ' - ' + (Get-Date -UFormat "%m/%d/%Y")
  if( $TblError.length -gt 32500) {
	$TblError = $TblError.SubString(0,32500)
  }
  $Description = '* *Error Message:* ' +  $TblError +
  '
                * *Database:* ' + $FirstDB +
  '
                * *ScenarioID:* ' + $FirstScenario +
  '
                * *DataFeedID:* ' + $FirstDFId +
  '
                * *Tablename/ProcessName:* ' + $FirstSP

  #$CustomBox='Job Failure Message: '+$cmd.message+
  #'
  #TaskqueueError: '+$tblTaskError.ErrorMessage

  #From Servers.CSV
  $ProjectNameinJira = $Projname
  #Default Priority
  $Priority = "High"
  #$Assignee=(invoke-sqlcmd -query "select settingvalue from TPS_DBA.dbo.tblServerSetting where SettingName='CSPRep'" -ServerInstance $PickaServer)
  #For Epics Previously Done. 
  $DeploymentDay = (Get-Date).DayOfWeek
  #$Labels=$Labels.split(",")

  $secpasswd = ConvertTo-SecureString 'igfkp4eylAVWDHaK7pfN32E4' -AsPlainText -Force #  get-content C:\IMS\cred.txt | convertto-securestring
  $cred = New-Object System.Management.Automation.PSCredential ("jirabot@shyftanalytics.com",$secpasswd)
  Set-JiraConfigServer 'https://trinitypharmasolutions.atlassian.net'
  try {
    Write-Log -Message "Connecting to JIRA"
    $Session = New-JiraSession -Credential $cred
  }
  catch { Write-Log -Message $_.Exception.Message -Severity 3
		
		$payload = @{
			"channel" = "#prod_bot"
			"icon_emoji" = ":autobot:" 
			"text" = "*Production Issue Ticket Failed to be created on $localServer*"
			"username" = "Optimus Prod"
			"color"="green"
		}
		Invoke-WebRequest `
			-Body (ConvertTo-Json -Compress -InputObject $payload) `
			-Method Post `
			-Uri 'https://hooks.slack.com/services/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' | Out-Null
	
    break }

  #Deprecated with move to project-specific orgs. 
  #Grab sprint ID from CSP Active Board
  #Write-Host "Step 4: Getting current Sprint ID" 
  #$new2=Invoke-JiraMethod -URI "$(Get-JiraConfigServer)/rest/greenhopper/latest/sprintquery/118?/includeHistoricSprints=false&includeClosedSprints=false" -Method Get
  #$SprintObj=$new2.sprints|Where-Object {$_.state -eq 'ACTIVE'}
  #$sprintid=$SprintObj.id

  if ($Priority -eq "High") { $Priority = "3" }
  if ($Priority -eq "Medium") { $Priority = "4" }
  if ($Priority -eq "Low") { $Priority = "5" }

  #$custfield='Job: '+$NoJob+'
  #Job Step: '+$cmd.step_name+'
  #SP/Table: '+$tblTaskError.'Relevant Info'

  if ($DeploymentDay -eq 'Monday') { $CSPEpic = "CSP-1" }
  if ($DeploymentDay -eq 'Tuesday') { $CSPEpic = "CSP-2" }
  if ($DeploymentDay -eq 'Wednesday') { $CSPEpic = "CSP-3" }
  if ($DeploymentDay -eq 'Thursday') { $CSPEpic = "CSP-4" }
  if ($DeploymentDay -eq 'Friday') { $CSPEpic = "CSP-5" }
  if ($DeploymentDay -eq 'Saturday') { $CSPEpic = "CSP-12" }
  if ($DeploymentDay -eq 'Sunday') { $CSPEpic = "CSP-13" }
 

$NewRep=Get-JiraUser -UserName $Rep|Select-Object -ExpandProperty AccountId

  $parametersforjira = @{

    Project = $ProjectNameinJira
    Priority = $Priority
    IssueType = 'Production Issue'

    Summary = $Title
    Description = $Description
    #Labels =  $Lables

    Fields = @{
      customfield_10200 = @{ value = "No" }
      customfield_10300 = @{ value = "SHYFT Analytics" }
      customfield_13302 = @{ value = "No" }
      customfield_13371 = @{ value = "No" }
      customfield_13374 = @{ value = "Data Provider" }
      #customfield_13305 = @{value=$ProjectNameinJira}
      customfield_10008 = $CSPEpic
      #customfield_11100 = @{value = "Not Selected"}
      #customfield_10007 =$sprintid
      assignee = @{ accountId = $NewRep }
      #customfield_13314=$custfield
      #customfield_13316=$CustomBox

    }
  }
  try {
    Write-Log -Message "Step 4: Final Step-Creating JIRA Ticket-Communicating with Server"
    $IssueCreated = New-JiraIssue @parametersforjira -ErrorAction 'Stop'
    Write-Log -Message "Created Ticket $IssueCreated"
  }
  catch { Write-Log -Message $_.Exception.Message -Severity 3
		
		$payload = @{
			"channel" = "#prod_bot"
			"icon_emoji" = ":autobot:" 
			"text" = "*Production Issue Ticket Failed to be created on $localServer*"
			"username" = "Optimus Prod"
			"color"="green"
		}
		Invoke-WebRequest `
			-Body (ConvertTo-Json -Compress -InputObject $payload) `
			-Method Post `
			-Uri 'https://hooks.slack.com/services/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' | Out-Null
	
    break }
	
	try {
    Write-Log -Message "Step 5: Update JIRA Ticket"
	$IssueKeyID=$IssueCreated.Key
	$RunTicketNumberSQL = invoke-sqlcmd -query "select SettingValue from tps_dba.dbo.tblserversetting where settingname like 'ActiveRunTicket'"-ServerInstance localhost
	$RunTicketNumber = $RunTicketNumberSQL.SettingValue
	$_issueLink = [PSCustomObject]@{
		outwardIssue = [PSCustomObject]@{key = $RunTicketNumber}    
		type = [PSCustomObject]@{name = "Blocks"}
	}
	$IssueUpdated = Add-JiraIssueLink -Issue $IssueKeyID -IssueLink $_issueLink  -ErrorAction 'Stop' 
	
	$fields = @{
        customfield_11100 = @{value = 'No'}
    }
 
	$IssueUpdated2 = Set-JiraIssue -Issue $RunTicketNumber -Fields $fields   -ErrorAction 'Stop' 
    Write-Log -Message "Updated Ticket $IssueUpdated $IssueUpdated2"
	}
	
  catch { Write-Log -Message $_.Exception.Message -Severity 3
		
		$payload = @{
			"channel" = "#prod_bot"
			"icon_emoji" = ":autobot:" 
			"text" = "*Production Issue Ticket Failed to be created on $localServer*"
			"username" = "Optimus Prod"
			"color"="green"
		}
		Invoke-WebRequest `
			-Body (ConvertTo-Json -Compress -InputObject $payload) `
			-Method Post `
			-Uri 'https://hooks.slack.com/services/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' | Out-Null
	
    break }
	
  #RandomQuoteForSlackMessage
  $quotearray = @("There's too many people on this earth. We need a new plague. - Dwight Schrute",
    "Dwight, you ignorant bot! - Michael Scott",
    "The worst thing about prison was--was the Dementors. - Michael Scott",
    "Sometimes I'll start a sentence and I don't even know where it's going I just hope I find it along the way. - Michael Scott",
    "I am running away from my responsibilities. And it feels good. - Michael Scott",
    "Identity theft is not a joke Jim! Millions of families suffer every year! - Dwight Schrute",
    "Well how the turntables... - Michael Scott",
    "Did I stutter?! - Stanley",
    "I talk a lot, so I've learned to just tune myself out. - Surya",
    "Oh, it is on, like a prawn who yawns at dawn. - Andy",
    "Should have burned this place down when I had the chance. - Michael Scott",
    "Mini cupcakes? As in the mini version of regular cupcakes? Which is already a mini version of cake? Honestly, where does it end with you people? - Kevin",
    "Whenever I'm about to do something, I think, 'Would an idiot do that?' And if they would, I do not do that thing. - Dwight Schrute",
    "I stopped caring a long time ago. - Creed",
    "It takes an advanced sense of humor. I don't expect everybody to understand. - Michael Scott",
    "The doctor said, if I can't find a new way to relate more positively to my surroundings, I'm going to die... I'm going to die. - Stanley",
    "I'm not superstitious, but I am a little stitious. - Michael Scott",
    "YOU ONLY LIVE ONCE? FALSE. YOU LIVE EVERYDAY. YOU ONLY DIE ONCE. - Dwight",
    "Come on, guys. Early worm gets the worm. - Michael Scott",
    "An office is a place where dreams come true. - Michael Scott",
    "I wish there was a way to know you're in the good old days before you've actually left them. - Andy",
    "If I don't have some cake soon, I might die. - Stanley",
    "I knew exactly what to do. But in a much more real sense, I had no idea what to do. - Michael Scott",
    "Sorry I annoyed you with my friendship. - Andy",
    "I just wanna lie on the beach and eat hot dogs. That's all I've ever wanted. - Kevin",
    "Everybody stay calm! Everybody stay calm! - Michael Scott",
    "Wikipedia is the best thing ever. Anyone in the world can write anything they want about any subject. So you know you are getting the best possible information. - Michael scott",
    "No! god! Please no! - Michael scott",
    "And I'm optimistic, but every day I get a little more desperate. - Michael scott",
    "I don't wanna work! I just wanna bang on this mug all day. - Michael scott",
    "I don't hate it. I just don't like it at all and it's terrible. - Michael scott",
    "I saved a life. my own. Am I a hero? I really can't say, but yes! - Michael scott",
    "You know what they say. 'fool me once, strike one. But fool me twice, strike three. - Michael Scott")

  $OptimusQuote = $quotearray[(Get-Random -Maximum ([array]$quotearray).count)]

  Remove-JiraSession
  
  $Output = 'Issue Key: ' + $IssueCreated.Key + '
Issue Summary: ' + $IssueCreated.Summary

  $Issuekey = $IssueCreated.Key
  $MessageURL = 'https://trinitypharmasolutions.atlassian.net/browse/' + $Issuekey

$SlackChannel=invoke-sqlcmd -query "Select SettingValue from TPS_DBA.dbo.tblserversetting where settingname='SlackFailChannel'"-ServerInstance localhost #$PickaServer
$SlackChannel=$SlackChannel.settingvalue -split ","
foreach($channel in $SlackChannel){
        if ($SlackChannel -ne $null ){
 $payload = @{
    "channel" = $Channel
    "icon_emoji" = ":autobot:"
    "text" = "Issue $Title was created: $MessageURL 
>>> $OptimusQuote"
    "username" = "Optimus Prod"
  }
  try {
    Write-Log -Message "Posting to Slack for $MessageURL"

    Invoke-WebRequest `
       -Body (ConvertTo-Json -Compress -InputObject $payload) `
       -Method Post `
       -Uri 'https://hooks.slack.com/services/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' | Out-Null

  }
  catch { Write-Log -Message $_.Exception.Message -Severity 3
		
		$payload = @{
			"channel" = "#prod_bot"
			"icon_emoji" = ":autobot:" 
			"text" = "*Production Issue Ticket Failed to be created on $localServer*"
			"username" = "Optimus Prod"
			"color"="green"
		}
		Invoke-WebRequest `
			-Body (ConvertTo-Json -Compress -InputObject $payload) `
			-Method Post `
			-Uri 'https://hooks.slack.com/services/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' | Out-Null
	 BREAK }
}
}

 exit 




# SIG # Begin signature block
# MIIgAQYJKoZIhvcNAQcCoIIf8jCCH+4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUhV5IJh/4kbXu1p3RVpUVUhSW
# 5XigghtoMIIDtzCCAp+gAwIBAgIQDOfg5RfYRv6P5WD8G/AwOTANBgkqhkiG9w0B
# AQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVk
# IElEIFJvb3QgQ0EwHhcNMDYxMTEwMDAwMDAwWhcNMzExMTEwMDAwMDAwWjBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCtDhXO5EOAXLGH87dg
# +XESpa7cJpSIqvTO9SA5KFhgDPiA2qkVlTJhPLWxKISKityfCgyDF3qPkKyK53lT
# XDGEKvYPmDI2dsze3Tyoou9q+yHyUmHfnyDXH+Kx2f4YZNISW1/5WBg1vEfNoTb5
# a3/UsDg+wRvDjDPZ2C8Y/igPs6eD1sNuRMBhNZYW/lmci3Zt1/GiSw0r/wty2p5g
# 0I6QNcZ4VYcgoc/lbQrISXwxmDNsIumH0DJaoroTghHtORedmTpyoeb6pNnVFzF1
# roV9Iq4/AUaG9ih5yLHa5FcXxH4cDrC0kqZWs72yl+2qp/C3xag/lRbQ/6GW6whf
# GHdPAgMBAAGjYzBhMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0G
# A1UdDgQWBBRF66Kv9JLLgjEtUYunpyGd823IDzAfBgNVHSMEGDAWgBRF66Kv9JLL
# gjEtUYunpyGd823IDzANBgkqhkiG9w0BAQUFAAOCAQEAog683+Lt8ONyc3pklL/3
# cmbYMuRCdWKuh+vy1dneVrOfzM4UKLkNl2BcEkxY5NM9g0lFWJc1aRqoR+pWxnmr
# EthngYTffwk8lOa4JiwgvT2zKIn3X/8i4peEH+ll74fg38FnSbNd67IJKusm7Xi+
# fT8r87cmNW1fiQG2SVufAQWbqz0lwcy2f8Lxb4bG+mRo64EtlOtCt/qMHt1i8b5Q
# Z7dsvfPxH2sMNgcWfzd8qVttevESRmCD1ycEvkvOl77DZypoEd+A5wwzZr8TDRRu
# 838fYxAe+o0bJW1sj6W3YQGx0qMmoRBxna3iw/nDmVG3KwcIzi7mULKn+gpFL6Lw
# 8jCCBTAwggQYoAMCAQICEAQJGBtf1btmdVNDtW+VUAgwDQYJKoZIhvcNAQELBQAw
# ZTELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBS
# b290IENBMB4XDTEzMTAyMjEyMDAwMFoXDTI4MTAyMjEyMDAwMFowcjELMAkGA1UE
# BhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2lj
# ZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUg
# U2lnbmluZyBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAPjTsxx/
# DhGvZ3cH0wsxSRnP0PtFmbE620T1f+Wondsy13Hqdp0FLreP+pJDwKX5idQ3Gde2
# qvCchqXYJawOeSg6funRZ9PG+yknx9N7I5TkkSOWkHeC+aGEI2YSVDNQdLEoJrsk
# acLCUvIUZ4qJRdQtoaPpiCwgla4cSocI3wz14k1gGL6qxLKucDFmM3E+rHCiq85/
# 6XzLkqHlOzEcz+ryCuRXu0q16XTmK/5sy350OTYNkO/ktU6kqepqCquE86xnTrXE
# 94zRICUj6whkPlKWwfIPEvTFjg/BougsUfdzvL2FsWKDc0GCB+Q4i2pzINAPZHM8
# np+mM6n9Gd8lk9ECAwEAAaOCAc0wggHJMBIGA1UdEwEB/wQIMAYBAf8CAQAwDgYD
# VR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUFBwMDMHkGCCsGAQUFBwEBBG0w
# azAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tMEMGCCsGAQUF
# BzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVk
# SURSb290Q0EuY3J0MIGBBgNVHR8EejB4MDqgOKA2hjRodHRwOi8vY3JsNC5kaWdp
# Y2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3JsMDqgOKA2hjRodHRw
# Oi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURSb290Q0EuY3Js
# ME8GA1UdIARIMEYwOAYKYIZIAYb9bAACBDAqMCgGCCsGAQUFBwIBFhxodHRwczov
# L3d3dy5kaWdpY2VydC5jb20vQ1BTMAoGCGCGSAGG/WwDMB0GA1UdDgQWBBRaxLl7
# KgqjpepxA8Bg+S32ZXUOWDAfBgNVHSMEGDAWgBRF66Kv9JLLgjEtUYunpyGd823I
# DzANBgkqhkiG9w0BAQsFAAOCAQEAPuwNWiSz8yLRFcgsfCUpdqgdXRwtOhrE7zBh
# 134LYP3DPQ/Er4v97yrfIFU3sOH20ZJ1D1G0bqWOWuJeJIFOEKTuP3GOYw4TS63X
# X0R58zYUBor3nEZOXP+QsRsHDpEV+7qvtVHCjSSuJMbHJyqhKSgaOnEoAjwukaPA
# JRHinBRHoXpoaK+bp1wgXNlxsQyPu6j4xRJon89Ay0BEpRPw5mQMJQhCMrI2iiQC
# /i9yfhzXSUWW6Fkd6fp0ZGuy62ZD2rOwjNXpDd32ASDOmTFjPQgaGLOBm0/GkxAG
# /AeB+ova+YJJ92JuoVP6EpQYhS6SkepobEQysmah5xikmmRR7zCCBTYwggQeoAMC
# AQICEA5CTGmLZfOiN2axclY2DLgwDQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMC
# VVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0
# LmNvbTExMC8GA1UEAxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIENvZGUgU2ln
# bmluZyBDQTAeFw0xOTA4MjAwMDAwMDBaFw0yMjA5MjYxMjAwMDBaMHMxCzAJBgNV
# BAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRzMRAwDgYDVQQHEwdXYWx0aGFt
# MRwwGgYDVQQKExNTaHlmdCBBbmFseXRpY3MgSW5jMRwwGgYDVQQDExNTaHlmdCBB
# bmFseXRpY3MgSW5jMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsbmY
# xxL/imxS0n267Ze1gmpv9CHD71HgInntr8rYAD/Hgp9beDK45J7LR6Adwpd4Rkl4
# spd65a7NdSpel5h4biIN4dVwW8o+pnc6fVofax7rH6+eXOV1aW7/ctg7ESS1ppoF
# HPX+tA+c15RNSL01V1t+98dC3ZNrP9PmQSQ3E0QryULVFfNYeJVJ6Wa2cwJL34Ln
# 70lGh7sNcheScHnr1PJOxSqGOKwY6K5levYUqL2GfnT9u31OD6WfTOOa7wAkrcfV
# 5s8YLIE0iwVL0Ye3GVlNXy+z1BGDboA+FWIEPXuuLeRgegiGfPGm/JTMTkgqFx2U
# ueuQs2RJF3OZ1Ep1wQIDAQABo4IBxTCCAcEwHwYDVR0jBBgwFoAUWsS5eyoKo6Xq
# cQPAYPkt9mV1DlgwHQYDVR0OBBYEFBQu/BOkhNO2FgNlVZkxiEOj0tG0MA4GA1Ud
# DwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzB3BgNVHR8EcDBuMDWgM6Ax
# hi9odHRwOi8vY3JsMy5kaWdpY2VydC5jb20vc2hhMi1hc3N1cmVkLWNzLWcxLmNy
# bDA1oDOgMYYvaHR0cDovL2NybDQuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC1j
# cy1nMS5jcmwwTAYDVR0gBEUwQzA3BglghkgBhv1sAwEwKjAoBggrBgEFBQcCARYc
# aHR0cHM6Ly93d3cuZGlnaWNlcnQuY29tL0NQUzAIBgZngQwBBAEwgYQGCCsGAQUF
# BwEBBHgwdjAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29tME4G
# CCsGAQUFBzAChkJodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNlcnRT
# SEEyQXNzdXJlZElEQ29kZVNpZ25pbmdDQS5jcnQwDAYDVR0TAQH/BAIwADANBgkq
# hkiG9w0BAQsFAAOCAQEAvts6JqE2JOvkdnCQAcxWZ+1br7nPODec63ZaSSlQ+cny
# b0hglZso3MCAhjC2Y2DdaX6INOzfZM7OYc2selouC/5ekp/smR0iyQGsdS30aIqr
# Nr90jkrJ59Cvh2DpCFi5F4lLnZ+NCGjGzBAs54omrKKm2fwXkpv1y0lFsPvWd7fI
# 3v9EVA2N9idtsEv6oUMht13jIUu3iZBhwJza+2QBcJSrdJaDZ3yVEsZl+8K1ScY6
# OesKA0g2O5LhAf1wwkc3+rqpDm1dZjYEAiRkZzANg1jDgzR8Js95KiIa/lmsv1hx
# jiDwjKJAHPmGwltd4gk4Yx6QgqTOfOq7oWtvAgC7/jCCBmowggVSoAMCAQICEAMB
# mgI6/1ixa9bV6uYX8GYwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEh
# MB8GA1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBDQS0xMB4XDTE0MTAyMjAwMDAw
# MFoXDTI0MTAyMjAwMDAwMFowRzELMAkGA1UEBhMCVVMxETAPBgNVBAoTCERpZ2lD
# ZXJ0MSUwIwYDVQQDExxEaWdpQ2VydCBUaW1lc3RhbXAgUmVzcG9uZGVyMIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo2Rd/Hyz4II14OD2xirmSXU7zG7g
# U6mfH2RZ5nxrf2uMnVX4kuOe1VpjWwJJUNmDzm9m7t3LhelfpfnUh3SIRDsZyeX1
# kZ/GFDmsJOqoSyyRicxeKPRktlC39RKzc5YKZ6O+YZ+u8/0SeHUOplsU/UUjjoZE
# VX0YhgWMVYd5SEb3yg6Np95OX+Koti1ZAmGIYXIYaLm4fO7m5zQvMXeBMB+7NgGN
# 7yfj95rwTDFkjePr+hmHqH7P7IwMNlt6wXq4eMfJBi5GEMiN6ARg27xzdPpO2P6q
# QPGyznBGg+naQKFZOtkVCVeZVjCT88lhzNAIzGvsYkKRrALA76TwiRGPdwIDAQAB
# o4IDNTCCAzEwDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/
# BAwwCgYIKwYBBQUHAwgwggG/BgNVHSAEggG2MIIBsjCCAaEGCWCGSAGG/WwHATCC
# AZIwKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwggFk
# BggrBgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBzAGUAIABvAGYAIAB0AGgAaQBz
# ACAAQwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBvAG4AcwB0AGkAdAB1AHQAZQBz
# ACAAYQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAgAHQAaABlACAARABpAGcAaQBD
# AGUAcgB0ACAAQwBQAC8AQwBQAFMAIABhAG4AZAAgAHQAaABlACAAUgBlAGwAeQBp
# AG4AZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBtAGUAbgB0ACAAdwBoAGkAYwBo
# ACAAbABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0AHkAIABhAG4AZAAgAGEAcgBl
# ACAAaQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABoAGUAcgBlAGkAbgAgAGIAeQAg
# AHIAZQBmAGUAcgBlAG4AYwBlAC4wCwYJYIZIAYb9bAMVMB8GA1UdIwQYMBaAFBUA
# EisTmLKZB+0e36K+Vw0rZwLNMB0GA1UdDgQWBBRhWk0ktkkynUoqeRqDS/QeicHK
# fTB9BgNVHR8EdjB0MDigNqA0hjJodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGln
# aUNlcnRBc3N1cmVkSURDQS0xLmNybDA4oDagNIYyaHR0cDovL2NybDQuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5jcmwwdwYIKwYBBQUHAQEEazBp
# MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wQQYIKwYBBQUH
# MAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJ
# RENBLTEuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCdJX4bM02yJoFcm4bOIyAPgIfl
# iP//sdRqLDHtOhcZcRfNqRu8WhY5AJ3jbITkWkD73gYBjDf6m7GdJH7+IKRXrVu3
# mrBgJuppVyFdNC8fcbCDlBkFazWQEKB7l8f2P+fiEUGmvWLZ8Cc9OB0obzpSCfDs
# cGLTYkuw4HOmksDTjjHYL+NtFxMG7uQDthSr849Dp3GdId0UyhVdkkHa+Q+B0Zl0
# DSbEDn8btfWg8cZ3BigV6diT5VUW8LsKqxzbXEgnZsijiwoc5ZXarsQuWaBh3drz
# baJh6YoLbewSGL33VVRAA5Ira8JRwgpIr7DUbuD0FAo6G+OPPcqvao173NhEMIIG
# zTCCBbWgAwIBAgIQBv35A5YDreoACus/J7u6GzANBgkqhkiG9w0BAQUFADBlMQsw
# CQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cu
# ZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBBc3N1cmVkIElEIFJvb3Qg
# Q0EwHhcNMDYxMTEwMDAwMDAwWhcNMjExMTEwMDAwMDAwWjBiMQswCQYDVQQGEwJV
# UzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQu
# Y29tMSEwHwYDVQQDExhEaWdpQ2VydCBBc3N1cmVkIElEIENBLTEwggEiMA0GCSqG
# SIb3DQEBAQUAA4IBDwAwggEKAoIBAQDogi2Z+crCQpWlgHNAcNKeVlRcqcTSQQaP
# yTP8TUWRXIGf7Syc+BZZ3561JBXCmLm0d0ncicQK2q/LXmvtrbBxMevPOkAMRk2T
# 7It6NggDqww0/hhJgv7HxzFIgHweog+SDlDJxofrNj/YMMP/pvf7os1vcyP+rFYF
# kPAyIRaJxnCI+QWXfaPHQ90C6Ds97bFBo+0/vtuVSMTuHrPyvAwrmdDGXRJCgeGD
# boJzPyZLFJCuWWYKxI2+0s4Grq2Eb0iEm09AufFM8q+Y+/bOQF1c9qjxL6/siSLy
# axhlscFzrdfx2M8eCnRcQrhofrfVdwonVnwPYqQ/MhRglf0HBKIJAgMBAAGjggN6
# MIIDdjAOBgNVHQ8BAf8EBAMCAYYwOwYDVR0lBDQwMgYIKwYBBQUHAwEGCCsGAQUF
# BwMCBggrBgEFBQcDAwYIKwYBBQUHAwQGCCsGAQUFBwMIMIIB0gYDVR0gBIIByTCC
# AcUwggG0BgpghkgBhv1sAAEEMIIBpDA6BggrBgEFBQcCARYuaHR0cDovL3d3dy5k
# aWdpY2VydC5jb20vc3NsLWNwcy1yZXBvc2l0b3J5Lmh0bTCCAWQGCCsGAQUFBwIC
# MIIBVh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAgAHQAaABpAHMAIABDAGUAcgB0
# AGkAZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0AHUAdABlAHMAIABhAGMAYwBl
# AHAAdABhAG4AYwBlACAAbwBmACAAdABoAGUAIABEAGkAZwBpAEMAZQByAHQAIABD
# AFAALwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABSAGUAbAB5AGkAbgBnACAAUABh
# AHIAdAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3AGgAaQBjAGgAIABsAGkAbQBp
# AHQAIABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBkACAAYQByAGUAIABpAG4AYwBv
# AHIAcABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBuACAAYgB5ACAAcgBlAGYAZQBy
# AGUAbgBjAGUALjALBglghkgBhv1sAxUwEgYDVR0TAQH/BAgwBgEB/wIBADB5Bggr
# BgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNv
# bTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lD
# ZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDov
# L2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6
# oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElE
# Um9vdENBLmNybDAdBgNVHQ4EFgQUFQASKxOYspkH7R7for5XDStnAs0wHwYDVR0j
# BBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJKoZIhvcNAQEFBQADggEBAEZQ
# Psm3KCSnOB22WymvUs9S6TFHq1Zce9UNC0Gz7+x1H3Q48rJcYaKclcNQ5IK5I9G6
# OoZyrTh4rHVdFxc0ckeFlFbR67s2hHfMJKXzBBlVqefj56tizfuLLZDCwNK1lL1e
# T7EF0g49GqkUW6aGMWKoqDPkmzmnxPXOHXh2lCVz5Cqrz5x2S+1fwksW5EtwTACJ
# HvzFebxMElf+X+EevAJdqP77BzhPDcZdkbkPZ0XN1oPt55INjbFpjE/7WeAjD9Kq
# rgB87pxCDs+R1ye3Fu4Pw718CqDuLAhVhSK46xgaTfwqIa1JMYNHlXdx3LEbS0sc
# EJx3FMGdTy9alQgpECYxggQDMIID/wIBATCBhjByMQswCQYDVQQGEwJVUzEVMBMG
# A1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMTEw
# LwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQgSUQgQ29kZSBTaWduaW5nIENB
# AhAOQkxpi2XzojdmsXJWNgy4MAkGBSsOAwIaBQCgQDAZBgkqhkiG9w0BCQMxDAYK
# KwYBBAGCNwIBBDAjBgkqhkiG9w0BCQQxFgQUvCZtkIyl3nYvYuBI4Ce43zYe3YYw
# DQYJKoZIhvcNAQEBBQAEggEAf3rfZdJzchAfpsJy7WGqyNAWMSANJsu2DM5n2kZ9
# IZvDhFyG25lkN2REaPgV7LPPyHHtWvOFzL38xpXL26iaAZgFg8CE1yw5r5mGzfFA
# pZY82QY3QsteitRIIcnE2nqt73TCWkpKibczbJE1k/opHfFRdZHp2nOHW0q4HsGQ
# kWxyUNXADnAUXmlME+HXjEGUZMY5hHM3rg3kExi3ROQWbuDSIvNVUKQBga8QdQas
# T4jlXUrMkcP4RFnnkLltTkYh6x6pSvxTjg3KHAa2s2pnXIKHuXcstJLpKKTgLF+p
# eehmehs+3buo4VZ4qYlCEG0O2rGiQEtsSdn0mF5jXgPu+KGCAg8wggILBgkqhkiG
# 9w0BCQYxggH8MIIB+AIBATB2MGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERp
# Z2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMQIQAwGaAjr/WLFr1tXq5hfwZjAJBgUrDgMC
# GgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcN
# MjAwMzMwMjAxODIxWjAjBgkqhkiG9w0BCQQxFgQUc2Arfnhi40GHYyhMye36gjzI
# jyAwDQYJKoZIhvcNAQEBBQAEggEAVx9pG1dTc2h56nqetXbs/XK8fqCdVQkPownf
# dEoGtL9GNgcGAxwtmRhFASrmt9h2Mx94ZeJS3aSQt3JiQGed06kKiBenFZ1vSb6A
# HKW6nGyEdxHLSSePqo0dgHzg8LgH3TIc9K9imvTvOK2buSyma8LCNksNbGlD9j8X
# gNOGptw7nht2PNgo8Fv+cot7p0MZ8qIJNTIewELeSzpXCMUDJfFauP69jVuGK7G8
# WIaNLBBTEmIeSiebHp0MycsXiKzC5HhDzKMp8JTjUugvwdi7YoaMivWtqVqBjQXB
# 2yAKET9fe2iyx9vuVs9FMjtB+0uOxYaxTolojbFViWzYQUhMUA==
# SIG # End signature block
