<#
.SYNOPSIS
    Updates organization custom field via NinjaOne API

.DESCRIPTION
    Simple script to update organization custom fields using OAuth2 authentication.

.PARAMETER ApiUrl
    NinjaOne API base URL (e.g., https://api.ninjarmm.com)

.PARAMETER ClientId
    OAuth2 Client ID

.PARAMETER ClientSecret
    OAuth2 Client Secret

.PARAMETER OrganizationId
    Organization ID to update

.PARAMETER CustomFieldName
    Custom field name

.PARAMETER CustomFieldValue
    New field value

.EXAMPLE
    .\Update-OrganizationCustomField.ps1 "https://api.ninjarmm.com" "client-id" "client-secret" 123 "Department" "IT"

.NOTES
    Requires PowerShell 5.1+ and management scope permissions
#>

param(
    [Parameter(Position=0, Mandatory=$true)][string]$ApiUrl,
    [Parameter(Position=1, Mandatory=$true)][string]$ClientId,
    [Parameter(Position=2, Mandatory=$true)][string]$ClientSecret,
    [Parameter(Position=3, Mandatory=$true)][int]$OrganizationId,
    [Parameter(Position=4, Mandatory=$true)][string]$CustomFieldName,
    [Parameter(Position=5, Mandatory=$true)][string]$CustomFieldValue
)

function Get-AccessToken {
    $body = @{
        grant_type = "client_credentials"
        client_id = $ClientId
        client_secret = $ClientSecret
        scope = "management"
    }
    
    $response = Invoke-RestMethod -Uri "$ApiUrl/ws/oauth/token" -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
    return $response.access_token
}

function Update-CustomField {
    param([string]$Token)
    
    $headers = @{
        Authorization = "Bearer $Token"
        "Content-Type" = "application/json"
    }
    
    $body = @{
        $CustomFieldName = @{ value = $CustomFieldValue }
    } | ConvertTo-Json -Depth 3
    
    Invoke-RestMethod -Uri "$ApiUrl/v2/organization/$OrganizationId/custom-fields" -Method Patch -Headers $headers -Body $body
}

# Main execution
try {
    $token = Get-AccessToken
    Update-CustomField $token
    Write-Host "Updated '$CustomFieldName' to '$CustomFieldValue'" -ForegroundColor Green
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}