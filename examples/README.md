# NinjaOne API Examples

This directory contains example scripts demonstrating how to use the NinjaOne API for common tasks.

## Available Examples

### Update-OrganizationCustomField.ps1

Updates an organization custom field value via the NinjaOne API using secure credential handling.

**Usage:**
```powershell
# Set environment variables
$env:customfieldname = "Department"
$env:customfieldvalue = "IT Operations"

# Run the script
.\Update-OrganizationCustomField.ps1
```

**Configuration:**
- Set your API URL and Organization ID in the script (lines 19-20)
- Create custom fields for API credentials: `ninjaoneClientId`, `ninjaoneClientSecret`
- Set environment variables: `customfieldname`, `customfieldvalue`

**Features:**
- Secure credential handling via custom fields (any level)
- Environment variable input for automation
- OAuth2 authentication with client credentials flow
- Clean output with error handling
- Optimized for minimal code and maximum efficiency
- No command-line parameters needed

**Requirements:**
- PowerShell 5.1 or later
- API client with `management` scope permissions
- Custom fields: `ninjaoneClientId`, `ninjaoneClientSecret` (device, organization, or global level)
- Environment variables: `customfieldname`, `customfieldvalue`

**Security:**
- API credentials stored in custom fields (not in code or command line)
- No sensitive information exposed in process lists or logs
- Follows NinjaRMM security best practices

## API Endpoints Used

- `POST /ws/oauth/token` - OAuth2 token endpoint
- `PATCH /v2/organization/{id}/custom-fields` - Update organization custom fields