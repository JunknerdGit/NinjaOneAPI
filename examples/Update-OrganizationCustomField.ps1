<#
.SYNOPSIS
    Updates organization custom field via NinjaOne API

.DESCRIPTION
    Simple script to update organization custom fields using OAuth2 authentication.
    Reads API credentials from custom fields and parameters from environment variables.

.NOTES
    Requires PowerShell 5.1+ and management scope permissions
    Requires custom fields: ninjaoneClientId, ninjaoneClientSecret (any level)
    Requires environment variables: customFieldName, customFieldValue
#>

param()

# Script variables from environment
$CustomFieldName = $env:customfieldname
$CustomFieldValue = $env:customfieldvalue

# Configuration
$ErrorActionPreference = 'Continue'

# NinjaOne API configuration
$ApiUrl = "https://eu.ninjarmm.com"  # Set your NinjaOne API base URL
$OrganizationId = "1"  # Set your organization ID

# Read API credentials from custom fields
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
        throw "Missing API credentials. Ensure custom fields 'ninjaoneClientId' and 'ninjaoneClientSecret' are set."
    }
    
    if ([string]::IsNullOrEmpty($CustomFieldName) -or [string]::IsNullOrEmpty($CustomFieldValue)) {
        throw "Missing required parameters. Set environment variables 'customFieldName' and 'customFieldValue'."
    }
    
    $token = Get-AccessToken
    Update-CustomField $token | Out-Null
    Write-Host "Updated '$CustomFieldName' to '$CustomFieldValue'" -ForegroundColor Green
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
