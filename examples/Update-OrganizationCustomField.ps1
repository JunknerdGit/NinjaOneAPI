<#
.SYNOPSIS
    Updates an organization custom field value via NinjaOne API

.DESCRIPTION
    This script demonstrates how to update organization custom field values using the NinjaOne Public API.
    It supports OAuth2 authentication and handles API requests to modify custom field data.

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
        
        Write-Host "Requesting access token from NinjaOne API..."
        
        $response = Invoke-RestMethod -Uri $tokenUrl -Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
        
        if ($response.access_token) {
            Write-Host "Successfully obtained access token" -ForegroundColor Green
            return $response.access_token
        } else {
            throw "No access token received in response"
        }
    }
    catch {
        Write-Error "Failed to obtain access token: $($_.Exception.Message)"
        throw
    }
}

function Get-OrganizationCustomFields {
    param(
        [string]$ApiUrl,
        [string]$AccessToken,
        [int]$OrganizationId
    )
    
    try {
        $uri = "$ApiUrl/v2/organization/$OrganizationId/custom-fields"
        
        $headers = @{
            Authorization = "Bearer $AccessToken"
            Accept = "application/json"
        }
        
        Write-Host "Retrieving current custom fields for organization $OrganizationId..."
        
        $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
        
        return $response
    }
    catch {
        Write-Error "Failed to retrieve organization custom fields: $($_.Exception.Message)"
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
        
        # Create the request body with the custom field update
        $body = @{
            $FieldName = @{
                value = $FieldValue
            }
        } | ConvertTo-Json -Depth 3
        
        Write-Host "Updating custom field '$FieldName' for organization $OrganizationId..."
        Write-Host "Setting value to: $FieldValue" -ForegroundColor Cyan
        
        $response = Invoke-RestMethod -Uri $uri -Method Patch -Headers $headers -Body $body
        
        Write-Host "Successfully updated organization custom field!" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Error "Failed to update organization custom field: $($_.Exception.Message)"
        if ($_.Exception.Response) {
            $errorDetails = $_.Exception.Response | ConvertFrom-Json -ErrorAction SilentlyContinue
            if ($errorDetails) {
                Write-Host "API Error Details: $($errorDetails | ConvertTo-Json -Depth 2)" -ForegroundColor Red
            }
        }
        throw
    }
}

# Main execution
try {
    Write-Host "=== NinjaOne Organization Custom Field Update ===" -ForegroundColor Yellow
    Write-Host "Organization ID: $OrganizationId"
    Write-Host "Custom Field: $CustomFieldName"
    Write-Host "New Value: $CustomFieldValue"
    Write-Host ""
    
    # Step 1: Get access token
    $accessToken = Get-NinjaOneAccessToken -ApiUrl $ApiUrl -ClientId $ClientId -ClientSecret $ClientSecret
    
    # Step 2: Get current custom fields (optional - for verification)
    Write-Host ""
    $currentFields = Get-OrganizationCustomFields -ApiUrl $ApiUrl -AccessToken $accessToken -OrganizationId $OrganizationId
    
    if ($currentFields) {
        Write-Host "Current custom fields found: $($currentFields.PSObject.Properties.Name -join ', ')" -ForegroundColor Gray
    }
    
    # Step 3: Update the custom field
    Write-Host ""
    $result = Update-OrganizationCustomField -ApiUrl $ApiUrl -AccessToken $accessToken -OrganizationId $OrganizationId -FieldName $CustomFieldName -FieldValue $CustomFieldValue
    
    Write-Host ""
    Write-Host "=== Update Complete ===" -ForegroundColor Green
    Write-Host "Organization custom field '$CustomFieldName' has been updated successfully!"
}
catch {
    Write-Host ""
    Write-Host "=== Update Failed ===" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}