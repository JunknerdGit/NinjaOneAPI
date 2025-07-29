<#
.SYNOPSIS
    Updates organization custom field via NinjaOne API

.DESCRIPTION
    Simple script to update organization custom fields using OAuth2 authentication.
    Reads API credentials from custom fields and parameters from environment variables.

.NOTES
    Requires PowerShell 5.1+ and management scope permissions
    Requires custom fields: ninjaoneClientId, ninjaoneClientSecret (any level)
    Requires environment variables: customfieldname, customfieldvalue
#>

param()

# Configuration
$ErrorActionPreference = 'Continue'
$ApiUrl = "https://eu.ninjarmm.com"
$OrganizationId = "1"

# Get variables
$CustomFieldName = $env:customfieldname; $CustomFieldValue = $env:customfieldvalue
$ClientId = Ninja-Property-Get ninjaoneClientId; $ClientSecret = Ninja-Property-Get ninjaoneClientSecret

# Main execution
try {
    # Validation
    if (!$ClientId -or !$ClientSecret -or !$CustomFieldName -or !$CustomFieldValue) {
        throw "Missing credentials or parameters. Check custom fields and environment variables."
    }
    
    # Get access token
    $tokenResponse = Invoke-RestMethod -Uri "$ApiUrl/ws/oauth/token" -Method Post -Body @{
        grant_type = "client_credentials"; client_id = $ClientId; client_secret = $ClientSecret; scope = "management"
    } -ContentType "application/x-www-form-urlencoded"
    
    # Update custom field
    Invoke-RestMethod -Uri "$ApiUrl/v2/organization/$OrganizationId/custom-fields" -Method Patch -Headers @{
        Authorization = "Bearer $($tokenResponse.access_token)"; "Content-Type" = "application/json"
    } -Body (@{$CustomFieldName = $CustomFieldValue} | ConvertTo-Json) | Out-Null
    
    Write-Host "Updated '$CustomFieldName' to '$CustomFieldValue'" -ForegroundColor Green
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}