# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license.

# Note: Use of this script requires configuring app-only auth
# as described in README.md

Write-Host 'PowerShell Graph Tutorial - App Only'

# Load settings
$settings = Get-Content './settings.json' -ErrorAction Stop | Out-String | ConvertFrom-Json

$clientId = $settings.clientId
$tenantId = $settings.tenantId
$certificate = $settings.clientCertificate

# <AppOnlyAuthSnippet>
Connect-MgGraph -ClientId $clientId -TenantId $tenantId -CertificateName $certificate
# </AppOnlyAuthSnippet>

# <GetUsersSnippet>
Get-MgUser -Select "displayName,id,mail" -Top 25 -OrderBy "displayName"
# </GetUsersSnippet>
