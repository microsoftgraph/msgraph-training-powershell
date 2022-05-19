# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.

Write-Host 'PowerShell Graph Tutorial'

# Load settings
$settings = Get-Content './settings.json' -ErrorAction Stop | Out-String | ConvertFrom-Json

$clientId = $settings.clientId
$authTenant = $settings.authTenant
$graphScopes = $settings.graphUserScopes

# <UserAuthSnippet>
# Authenticate the user
Connect-MgGraph -ClientId $clientId -TenantId $authTenant -Scopes $graphScopes -UseDeviceAuthentication
# </UserAuthSnippet>

# <GetContextSnippet>
# Get the Graph context
Get-MgContext
# </GetContextSnippet>

# <SaveContextSnippet>
$context = Get-MgContext
# </SaveContextSnippet>

# <GetUserSnippet>
# Get the authenticated user by UPN
$user = Get-MgUser -UserId $context.Account -Select 'displayName, id, mail, userPrincipalName'
# </GetUserSnippet>

# <GreetUserSnippet>
Write-Host "Hello," $user.DisplayName
# For Work/school accounts, email is in Mail property
# Personal accounts, email is in UserPrincipalName
Write-Host "Email:", ($user.Mail ?? $user.UserPrincipalName)
# </GreetUserSnippet>

# <GetInboxSnippet>
Get-MgUserMailFolderMessage -UserId $user.Id -MailFolderId Inbox -Select `
  "from,isRead,receivedDateTime,subject" -OrderBy "receivedDateTime DESC" `
  -Top 25 | Format-Table Subject,@{n='From';e={$_.From.EmailAddress.Name}}, `
  IsRead,ReceivedDateTime
# </GetInboxSnippet>

# <DefineMailSnippet>
$sendMailParams = @{
    Message = @{
        Subject = "Testing Microsoft Graph"
        Body = @{
            ContentType = "text"
            Content = "Hello world!"
        }
        ToRecipients = @(
            @{
                EmailAddress = @{
                    Address = ($user.Mail ?? $user.UserPrincipalName)
                }
            }
        )
    }
}
# </DefineMailSnippet>

# <SendMailSnippet>
Send-MgUserMail -UserId $user.Id -BodyParameter $sendMailParams
# </SendMailSnippet>

Disconnect-MgGraph
