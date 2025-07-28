# NinjaOne API Examples

This directory contains example scripts demonstrating how to use the NinjaOne API for common tasks.

## Available Examples

### Update-OrganizationCustomField.ps1

Updates an organization custom field value via the NinjaOne API.

**Usage:**
```powershell
.\Update-OrganizationCustomField.ps1 -ApiUrl "https://api.ninjarmm.com" -ClientId "your-client-id" -ClientSecret "your-client-secret" -OrganizationId 123 -CustomFieldName "Department" -CustomFieldValue "IT Operations"
```

**Parameters:**
- `ApiUrl` - Your NinjaOne API base URL
- `ClientId` - OAuth2 Client ID
- `ClientSecret` - OAuth2 Client Secret  
- `OrganizationId` - Target organization ID
- `CustomFieldName` - Name of the custom field to update
- `CustomFieldValue` - New value for the custom field

**Features:**
- OAuth2 authentication with client credentials flow
- Error handling and detailed logging
- Retrieves current custom fields for verification
- Updates organization custom field via PATCH request

**Requirements:**
- PowerShell 5.1 or later
- API client with `management` scope permissions
- Valid organization ID and custom field name

## API Endpoints Used

- `POST /ws/oauth/token` - OAuth2 token endpoint
- `GET /v2/organization/{id}/custom-fields` - Get organization custom fields
- `PATCH /v2/organization/{id}/custom-fields` - Update organization custom fields