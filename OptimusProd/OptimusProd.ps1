#Load Required Info
#Author: Sam Bloch
#Please denote all Changes at the header of this file! (Ticket Numbers)
#Got rid of hard coded slack webhook URL 6/26/2020 - Todd Forman
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
  Install-Module SqlServer -Scope CurrentUser -Force
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
Add-Type -AssemblyName PresentationFramework


[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void][System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework")
try {
  New-Item -Path ".\OptimusProdLogs" -ItemType Directory -Force
  #Copy-Item -Path ".\Servers.csv" -Destination "D:\Servers\"
  Write-Log -Message "Created Directory for Logging"
}
catch { Write-Log -Message $_.Exception.Message -Severity 3
  break }
#ServerPicker
try {
  $DropDownArray = Invoke-Sqlcmd -Query "Select * from ApplicationServices.dbo.tblMDServers" -ServerInstance "PROSHFASDB1"
  $DropDownArray=$DropDownArray|Sort-Object -Property Name
  #Import-Csv D:\Servers\Servers.csv
}
catch { Write-Log -Message $_.Exception.Message -Severity 3
  break }
Write-Log -Message "Imported Server Listing from App Services Server"
$global:closescript = $false

function Return-DropDown {
  $script:Choice = $DropDown.SelectedItem.ToString()
  $Form.Close()
}

function ExitFlag {
  $global:closescript = $true
}


function selectShare {
  [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
  [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
  [void][System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework")


  $Form = New-Object System.Windows.Forms.Form
  $Form.AutoSize = $True
  $Form.AutoSizeMode = "GrowAndShrink"
  $Form.Text = "Jira Auto Bot"
  $Form.StartPosition = "CenterScreen"
  $Form.ControlBox = $false

  # $form.Controls.Add($listBox)


  $DropDown = New-Object System.Windows.Forms.ComboBox
  $DropDown.Location = New-Object System.Drawing.Size (100,10)
  $DropDown.AutoSize = $True
  #$DropDown.Size = new-object System.Drawing.Size(140,50)
  $DropDown.SelectedItem = $DropDown.Items[0]
  $DropDown.AutoCompleteMode = 'SuggestAppend'
  $DropDown.AutoCompleteSource = 'CustomSource'
  $DropDown.AutoCompleteCustomSource.AddRange($DropDownArray.Name)
  #$DropDown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList;
  foreach ($Item in $DropDownArray) {
    [void]$DropDown.Items.Add($Item.Name)
  }

  $Form.Controls.Add($DropDown)
  $Form.Topmost = $true
  $DropDown.SelectedIndex = 0


  $DropDownLabel = New-Object System.Windows.Forms.Label
  $DropDownLabel.Location = New-Object System.Drawing.Size (10,10)
  $DropDownLabel.AutoSize = $True #= new-object System.Drawing.Size(100,11) 
  $DropDownLabel.Text = "Select Client"
  $Form.Controls.Add($DropDownLabel)

  $Button = New-Object System.Windows.Forms.Button
  $Button.Location = New-Object System.Drawing.Size (50,50)
  $Button.AutoSize = $True # = new-object System.Drawing.Size(100,50)
  $Button.Text = "Create a JIRA Ticket"
  $Button.Add_Click({ Return-DropDown })
  $form.Controls.Add($Button)


  $QuitButton = New-Object System.Windows.Forms.Button
  $QuitButton.Location = New-Object System.Drawing.Size (200,50)
  $QuitButton.AutoSize = $True # = New-Object System.Drawing.Size(100,50)
  $QuitButton.Text = "Quit"
  $QuitButton.Add_Click({
      ExitFlag
      $Form.Close()
      return $closescript })
  $Form.Controls.Add($QuitButton)

  $FormLabel = New-Object System.Windows.Forms.Label
  $FormLabel.Text = "This is the Auto Jira Creator for the Production Team. (Optimus Prod) If you have any questions, please reach out to Sam Bloch at sbloch@shyftanalytics.com"
  $FormLabel.Location = New-Object System.Drawing.Size (10,100)
  $FormLabel.AutoSize = $True # = new-object System.Drawing.Size(485,400) 
  $Form.Controls.Add($FormLabel)

  $Form.Add_Shown({ $Form.Activate() })
  [void]$Form.ShowDialog()


  return $script:choice
}


$share = selectShare

#Dropdown Pulls
$Droplist = $DropDownArray | Where-Object { $_.Name -eq $share }
$ProjTitleName = $Droplist.Name
$PickaServer = $Droplist.Conn
$Rep = $env:UserName
$Projname = $Droplist.JiraProjectName
$Channel = $Droplist.SlackChannel

if ($closescript -eq $false) {
  Write-Host "Step 1: Gathering Error Information from SQL"
  #Job Failure SQL
  try {
    Write-Log -Message "Query Job Information for $PickaServer"
	Invoke-Sqlcmd -Query "EXEC TPS_DBA.dbo.uspFindLatestErrorInfo" -ServerInstance  $PickaServer -ErrorAction Stop
    $cmd = Invoke-Sqlcmd -Query "SELECT * FROM TPS_DBA.dbo.tblJobFailure" -ServerInstance $PickaServer  -ErrorAction Stop }
  catch { Write-Log -Message $_.Exception.Message -Severity 3
    break }
  try {
    Write-Log -Message "Query Error Information for $PickaServer"
    #Task Failure SQL
    $tblTaskError = Invoke-Sqlcmd -Query "SELECT DISTINCT * FROM TPS_DBA.dbo.tblLatestErrorInfo" -ServerInstance $PickaServer
  }
  catch { Write-Log -Message $_.Exception.Message -Severity 3
    break }
  $JobHasMessage = $cmd.Name
  $NoJob = if ($JobHasMessage -eq [System.DBNull]::Value) { "Job Independent Error" } else { $JobHasMessage }

  $FirstDB = $tblTaskError.DB | Select-Object -First 1
  
  $FirstScenario = $tblTaskError.Scenario | Select-Object -First 1
  $FirstDFId = $tblTaskError.DFid | Select-Object -First 1
  $FirstSP = $tblTaskError.SP | Select-Object -First 1
  $TblError=$tblTaskError.Error -join "`r`n`n* "|Out-String


  #$cmd.name
  #$cmd.step_name
  #$cmd.message
  #$cmd.run_date
  #$cmd.run_time
  Write-Host "Step 2: Formatting JIRA Ticket"
  #$Labels=@()
  Write-Log -Message "Formatting JIRA Ticket"
  #JIRA Formats
  $Title = '' + $ProjTitleName + ' - ' + $NoJob + ' - ' + (Get-Date -UFormat "%m/%d/%Y")
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
  Write-Host "Step 3: Connecting to JIRA"
  Set-JiraConfigServer 'https://trinitypharmasolutions.atlassian.net'
  try {
    Write-Log -Message "Connecting to JIRA"
    $Session = New-JiraSession -Credential $cred
  }
  catch { Write-Log -Message $_.Exception.Message -Severity 3
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
  
$Rep=invoke-sqlcmd -Query "Select * from TPS_DBA.dbo.tblserversetting where settingname='IssueTicketAssignee'" -Serverinstance $PickaServer|Select-Object -ExpandProperty SettingValue

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
      #assignee = @{ name = $Rep }
      #customfield_13314=$custfield
      #customfield_13316=$CustomBox

    }
  }
  Write-Host "Step 4: Final Step-Creating JIRA Ticket-Communicating with Server"
  try {
    Write-Log -Message "Step 4: Final Step-Creating JIRA Ticket-Communicating with Server"
    $IssueCreated = New-JiraIssue @parametersforjira -ErrorAction 'Stop'
    Write-Log -Message "Created Ticket $IssueCreated"

    $JiraTix=$IssueCreated.Key
       ##Search for An AccountID
    $params=@{
    
    Uri="$(Get-JiraConfigServer)/rest/api/3/user/search?query=$Rep"
    Method="GET"
    
    }
    
    $AcctID=Invoke-JiraMethod @params|Select-Object -ExpandProperty accountId
    
     ###Updating Issue to user ###
     $body='
                {"fields": {
           "assignee":{"accountId":"'+$AcctID+'"}
                }
                 }'   
    
            $Update=@{
            Uri="$(Get-JiraConfigServer)/rest/api/latest/issue/$JiraTix"
            Method="PUT"
            Body=$body
             }
             Invoke-JiraMethod @Update





  }
  catch { Write-Log -Message $_.Exception.Message -Severity 3
    break }
	
	try {
    Write-Log -Message "Step 5: Update JIRA Ticket"
	$IssueKeyID=$IssueCreated.Key
	$RunTicketNumberSQL = invoke-sqlcmd -query "select SettingValue from tps_dba.dbo.tblserversetting where settingname like 'ActiveRunTicket'"-ServerInstance $PickaServer
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
  		Write-Log -Message "JIRA Ticket WAS NOT Created"
    break }
	
	
  #RandomQuoteForSlackMessage
  $quotearray = @("There’s a thin line between being a hero and being a memory. - Optimus Prime",
    "Freedom is your right. If you make that request we will honor it.- Optimus Prime",
    "Give them personalities worthy of him who created me. Let them think for themselves, to grow in knowledge and wisdom. And let them always value freedom and life wherever they find it. - Optimus Prime",
    "Until I return I'm leaving you in command. I know you won't let me down. - Optimus Prime",
    "One shall stand, one shall fall. - Optimus Prime",
    "Do not forget what you have learned of our past, Rodimus. From its lessons the future is forged. - Optimus Prime",
    "Neither impossible, nor impassable! - Optimus Prime",
    "There’s only one way to deal with this, and that’s to stomp it flat. - Optimus Prime",
    "Your volume, like any capability, is also a responsibility. - Optimus Prime",
    "There's more to them than meets the eye. - Optimus Prime",
    "We must not stoop to their level. Megatron will not defeat us this easily. - Optimus Prime",
    "Thrones are for Decepticons. Besides, I’d rather roll. - Optimus Prime",
    "Thank you, all of you. You honor us with your bravery. - Optimus Prime",
    " I will accept the burden with all that I am. - Optimus Prime",
    "Freedom is the right of all sentient beings. - Optimus Prime",
    "I don’t have to tell you what’s ahead of us. They have to be stopped and we’re the only ones who can do it. - Optimus Prime",
    "Negative. Any action we take now would be viewed as admission of our guilt. - Optimus Prime",
    "You are going to face justice, and may it be kinder to you than it was to us. - Optimus Prime",
    " We can't transform, but we're not helpless. Autobots, roll for it. - Optimus Prime",
    "Your people must learn to be masters of their own fate. - Optimus Prime",
    "Are you going to let it all happen again for something as useless as revenge?! - Optimus Prime",
    "We cannot let the humans pay for our mistakes. - Optimus Prime",
    "We lost a great comrade, but gained new ones. - Optimus Prime",
    "I may not have a weapon, but I can still transform and roll. - Optimus Prime",
    "You didn't betray me. You betrayed yourself. - Optimus Prime",
    "Today, in the name of freedom, we take the battle to them. - Optimus Prime",
    "We’ve suffered losses, but we’ve not lost the war. - Optimus Prime",
    "Fate rarely calls upon us at a moment of our choosing. - Optimus Prime")

  $OptimusQuote = $quotearray[(Get-Random -Maximum ([array]$quotearray).count)]

  $Output = 'Click Yes to Open the Issue in Chrome, No to close AutoJira     
Issue Key: ' + $IssueCreated.Key + '
Issue Summary: ' + $IssueCreated.Summary
  Add-Type -AssemblyName PresentationFramework
  $Issuekey = $IssueCreated.Key
  $MessageURL = 'https://trinitypharmasolutions.atlassian.net/browse/' + $Issuekey

  $payload = @{
    "channel" = $Channel
    "icon_emoji" = ":autobot:"
    "text" = "Issue $Title was created: $MessageURL 
>>> $OptimusQuote"
    "username" = "Optimus Prod"
  }
  try {
    Write-Log -Message "Posting to Slack for $MessageURL"

    $SlackURL=invoke-sqlcmd "select settingvalue from TPS_DBA.dbo.tblserversetting where settingname='SlackURL'" -ServerInstance $PickaServer

    Invoke-WebRequest `
       -Body (ConvertTo-Json -Compress -InputObject $payload) `
       -Method Post `
       -Uri  $SlackURL.settingvalue| Out-Null -ErrorAction Stop

  }
  catch { Write-Log -Message $_.Exception.Message -Severity 3}
  $messageboxreply = [System.Windows.MessageBox]::Show("$Output","AutoJira",'YesNo',"Question")
  if ($messageboxreply -eq "Yes") {
    Start-Process "chrome.exe" $MessageURL }
  else {}
  Write-Host ('Ticket #: ' + $IssueCreated.Key + ' Ticket Title: ' + $IssueCreated.Summary)

  Remove-JiraSession


} else { exit }

# SIG # Begin signature block
# MIIgAQYJKoZIhvcNAQcCoIIf8jCCH+4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOJkSDWJKFlfGnkqfjtqUOrFO
# WBygghtoMIIDtzCCAp+gAwIBAgIQDOfg5RfYRv6P5WD8G/AwOTANBgkqhkiG9w0B
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
# KwYBBAGCNwIBBDAjBgkqhkiG9w0BCQQxFgQUGjBKTGvm8Q9Hc94yKrozUMqZGV0w
# DQYJKoZIhvcNAQEBBQAEggEATGpMLJgWM4/neUPD8j/RiRBKiIdUbJadsBfnozqs
# izUQB2zOd8LJyiXDjaE936aw7u3sLE6f6q/iD7GnScwPKs0qSLmO5ccN9KKvRhAk
# 31e+Kx5yIiRlJ17t2TusXfk9/F8REbIOFWRMxZpI9cvn8YGloYcnmNSJrigMI1/h
# ynPLXB8U6WW2HTBrAZsmCSvPlj0TX9OuXOIdwFEFYVp1tBUHsSRAAh18m5ztf7a7
# 3xVQGJZWLdYfy+t2ycLU/5DtKgFI5mBn/jOQI3su2+DwIWwS2+1eCqttnMD0xksJ
# FeVFDEYrmKf5OMgjyluDcVmWfGhe7ggPAog3tZdt/AM7raGCAg8wggILBgkqhkiG
# 9w0BCQYxggH8MIIB+AIBATB2MGIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdp
# Q2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xITAfBgNVBAMTGERp
# Z2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMQIQAwGaAjr/WLFr1tXq5hfwZjAJBgUrDgMC
# GgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcN
# MjAwNzAyMTQ0MDIxWjAjBgkqhkiG9w0BCQQxFgQUkocplilhFyf9ivrmJb01Xs8N
# YN0wDQYJKoZIhvcNAQEBBQAEggEAkj9aKHqRVPr63ulgby8joPX5lgYY4kk6rBMP
# Q0596KT6LogAeFcY0Yx2os4WCzESBmPf5Xp1raXvq29cWem3EH51s8tJNNx4oGFH
# G/qmg/J1g9wHy40XN8z+gw+dNLgdNfHABxG7NI/XE71vK2h1m+rcGWJbQuIEyrWE
# H1nIP6oh/WkFrgGeXjn8toUBei5FPAwbN3eEAPjkw0GZLujKx12hRc/Ko64kDiq0
# XjkKTquESW2xQbsC/L+rjntKiJGkHeToC8TTQKvWdHXi1H7VJg3WSTdw43oxR3ea
# IdvLiwi0MpuMS0acOGL7DLfgNcz5Le6Edq0GPy8s0ciYmmtCAw==
# SIG # End signature block
