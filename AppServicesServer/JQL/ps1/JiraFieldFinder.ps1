Import-Module JiraPS
$secpasswd = ConvertTo-SecureString 'igfkp4eylAVWDHaK7pfN32E4' -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ("jirabot@shyftanalytics.com",$secpasswd)
Set-JiraConfigServer 'https://trinitypharmasolutions.atlassian.net'
$Session = New-JiraSession -Credential $cred
Get-JiraIssue -Key "TES-6715"|Select-Object * # customfield_10008 
