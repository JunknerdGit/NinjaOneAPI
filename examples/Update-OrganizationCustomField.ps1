<#
.SYNOPSIS
    Updates organization custom field via NinjaOne API

.DESCRIPTION
    Simple script to update organization custom fields using OAuth2 authentication.
    Reads API credentials from device custom fields for security.

.PARAMETER CustomFieldName
    Custom field name

.PARAMETER CustomFieldValue
    New field value

.EXAMPLE
    .\Update-OrganizationCustomField.ps1 "Department" "IT"

.NOTES
    Requires PowerShell 5.1+ and management scope permissions
    Requires custom fields: ninjaoneClientId, ninjaoneClientSecret
#>

param(
    [Parameter(Position=0, Mandatory=$true)][string]$CustomFieldName,
    [Parameter(Position=1, Mandatory=$true)][string]$CustomFieldValue
)

# Configuration
$ErrorActionPreference = 'Continue'

# NinjaOne API configuration
$ApiUrl = "https://api.ninjarmm.com"  # Set your NinjaOne API base URL
$OrganizationId = 123  # Set your organization ID

# Read API credentials from device custom fields
$ClientId = Ninja-Property-Get ninjaoneClientId
$ClientSecret = Ninja-Property-Get ninjaoneClientSecret

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
    if ([string]::IsNullOrEmpty($ClientId) -or [string]::IsNullOrEmpty($ClientSecret)) {
        throw "Missing API credentials. Ensure custom fields 'ninjaoneClientId' and 'ninjaoneClientSecret' are set on this device."
    }
    
    $token = Get-AccessToken
    Update-CustomField $token
    Write-Host "Updated '$CustomFieldName' to '$CustomFieldValue'" -ForegroundColor Green
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}