# Microsoft 365 and Azure PowerShell Modules

This directory contains scripts for installing, updating, and managing Microsoft 365 and Azure PowerShell modules, along with helper functions for connecting to various Microsoft cloud services.

## Installation and Setup

The modules are automatically installed and updated as part of your PowerShell profile initialization. You can also manually install or update them using the following commands:

```powershell
# Update all M365 and Azure modules
Update-M365AzureModules

# Alias for updating M365 and Azure modules
updatem365
```

## Available Modules

The following Microsoft 365 and Azure modules are installed and managed:

### Microsoft Graph
- `Microsoft.Graph` - Microsoft Graph PowerShell SDK
- `Microsoft.Graph.Authentication` - Microsoft Graph Authentication module

### Exchange Online
- `ExchangeOnlineManagement` - Exchange Online PowerShell V3 module

### Azure
- `Az` - Azure PowerShell module
- `Az.Accounts` - Azure Accounts module
- `Az.Resources` - Azure Resources module

### Microsoft Teams
- `MicrosoftTeams` - Microsoft Teams PowerShell module

### SharePoint Online
- `PnP.PowerShell` - SharePoint PnP PowerShell module

### Azure AD
- `AzureAD` - Azure Active Directory PowerShell module

### MSOnline (Legacy)
- `MSOnline` - Microsoft Online Services module (legacy)

## Connection Functions

The following functions are available to connect to Microsoft cloud services:

### Microsoft 365

```powershell
# Connect to Microsoft 365 services (defaults to Exchange Online and Microsoft Graph)
Connect-M365

# Connect to specific M365 services
Connect-M365 -Exchange -Graph

# Connect with MFA
Connect-M365 -MFA

# Connect to a specific tenant
Connect-M365 -TenantId "contoso"

# Alias for Connect-M365
m365
```

### Azure

```powershell
# Connect to Azure
Connect-AzureCloud

# Connect to a specific subscription
Connect-AzureCloud -SubscriptionId "00000000-0000-0000-0000-000000000000"

# Connect to a specific tenant
Connect-AzureCloud -TenantId "00000000-0000-0000-0000-000000000000"

# Alias for Connect-AzureCloud
azure
```

### Disconnecting

```powershell
# Disconnect from Microsoft 365 services
Disconnect-M365
# Alias: m365exit

# Disconnect from Azure
Disconnect-AzureCloud
# Alias: azureexit
```

## Integration with PowerShell Profile

These modules and functions are automatically integrated with your PowerShell profile. The profile will:

1. Check for and install required modules during initialization
2. Provide convenient aliases for connecting to cloud services
3. Sync module installation scripts with your dotfiles repository

## Troubleshooting

If you encounter issues with the modules:

1. Run `Update-M365AzureModules -Force` to reinstall all modules
2. Check for connectivity issues to PowerShell Gallery
3. Ensure you have the latest PowerShell version installed

For more information on specific modules, refer to the Microsoft documentation:
- [Microsoft Graph PowerShell SDK](https://docs.microsoft.com/en-us/powershell/microsoftgraph/overview)
- [Exchange Online PowerShell](https://docs.microsoft.com/en-us/powershell/exchange/exchange-online-powershell)
- [Azure PowerShell](https://docs.microsoft.com/en-us/powershell/azure/overview)
