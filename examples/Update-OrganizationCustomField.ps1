<#
.SYNOPSIS
    Updates an organization custom field value via NinjaOne API

.DESCRIPTION
    This script updates organization custom field values using the NinjaOne Public API.
    It uses OAuth2 authentication and handles API requests efficiently.

.PARAMETER ApiUrl
    The base URL for your NinjaOne API instance (e.g., https://api.ninjarmm.com)

.PARAMETER ClientId
    OAuth2 Client ID for API authentication

.PARAMETER ClientSecret
    OAuth2 Client Secret for API authentication

.PARAMETER OrganizationId
    The ID of the organization to update

.PARAMETER CustomFieldName
    The name of the custom field to update

.PARAMETER CustomFieldValue
    The value to set for the custom field

.EXAMPLE
    .\Update-OrganizationCustomField.ps1 -ApiUrl "https://api.ninjarmm.com" -ClientId "your-client-id" -ClientSecret "your-client-secret" -OrganizationId 123 -CustomFieldName "Department" -CustomFieldValue "IT Operations"

.NOTES
    Requires PowerShell 5.1 or later
    Requires appropriate API permissions (management scope)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ApiUrl,
    
    [Parameter(Mandatory = $true)]
    [string]$ClientId,
    
    [Parameter(Mandatory = $true)]
    [string]$ClientSecret,
    
    [Parameter(Mandatory = $true)]
    [int]$OrganizationId,
    
    [Parameter(Mandatory = $true)]
    [string]$CustomFieldName,
    
    [Parameter(Mandatory = $true)]
    [string]$CustomFieldValue
)

function Get-NinjaOneAccessToken {
    param(
        [string]$ApiUrl,
        [string]$ClientId,
        [string]$ClientSecret
    )
    
    try {
        $tokenUrl = "$ApiUrl/ws/oauth/token"
        
        $body = @{
            grant_type = "client_credentials"
            client_id = $ClientId
            client_secret = $ClientSecret
            scope = "management"
        }
        
        Write-Host "Requesting access token..."
        
        $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
        
        if (-not $response.access_token) {
            throw "No access token received"
        }
        
        Write-Host "Access token obtained" -ForegroundColor Green
        return $response.access_token
    }
    catch {
        Write-Error "Failed to obtain access token: $($_.Exception.Message)"
        throw
    }
}

function Update-OrganizationCustomField {
    param(
        [string]$ApiUrl,
        [string]$AccessToken,
        [int]$OrganizationId,
        [string]$FieldName,
        [string]$FieldValue
    )
    
    try {
        $uri = "$ApiUrl/v2/organization/$OrganizationId/custom-fields"
        
        $headers = @{
            Authorization = "Bearer $AccessToken"
            "Content-Type" = "application/json"
            Accept = "application/json"
        }
        
        $body = @{
            $FieldName = @{
                value = $FieldValue
            }
        } | ConvertTo-Json -Depth 3
        
        Write-Host "Updating custom field '$FieldName' to '$FieldValue'..."
        
        $response = Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body $body
        
        Write-Host "Custom field updated successfully!" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Error "Failed to update custom field: $($_.Exception.Message)"
        throw
    }
}

# Main execution
try {
    Write-Host "=== NinjaOne Custom Field Update ===" -ForegroundColor Yellow
    
    # Get access token
    $accessToken = Get-NinjaOneAccessToken -ApiUrl $ApiUrl -ClientId $ClientId -ClientSecret $ClientSecret
    
    # Update the custom field
    $result = Update-OrganizationCustomField -ApiUrl $ApiUrl -AccessToken $accessToken -OrganizationId $OrganizationId -FieldName $CustomFieldName -FieldValue $CustomFieldValue
    
    Write-Host "Update completed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "Update failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}