#Sample script, provided with SSMSBoost add-in to send an e-mail using Outlook
param(
 [string]$subject="SSMSBoost script execution finished",
 [string]$statusTextFile,
 [string]$messagesFile,
 [string]$sqlScriptFile,
 [string]$recipient
 )

$outlook = New-Object -com Outlook.Application

$mail = $outlook.CreateItem(0)

if ($statusTextFile.length -gt 0)
{
	$body = [IO.File]::ReadAllText($statusTextFile)+"`n`n"
}
	
if ($messagesFile.length -gt 0)
{
	$body = $body+"Execution messages:`n"+[IO.File]::ReadAllText($messagesFile)+"`n`n"
}

if ($sqlScriptFile.length -gt 0)
{
	$body = $body+"Executed SQL Script:`n"+[IO.File]::ReadAllText($sqlScriptFile)
}

$mail.subject = $subject
$mail.body = $body
$mail.to = $recipient
$mail.Send()

#optionally, uncomment, if you want outlook to quit
#$outlook.Quit()