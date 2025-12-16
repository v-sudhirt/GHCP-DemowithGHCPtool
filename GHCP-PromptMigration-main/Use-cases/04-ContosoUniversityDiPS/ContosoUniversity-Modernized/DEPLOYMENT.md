# ContosoUniversity - Deployment Guide

## Quick Start

This guide walks through deploying the modernized ContosoUniversity application to Azure App Service.

## Phase 4: Infrastructure Generation  COMPLETED

The following infrastructure components have been generated:

### Generated Files

1. **Terraform Configuration**
   - `infra/main.tf` - Root configuration with provider and modules
   - `infra/variables.tf` - Input variables with validation
   - `infra/outputs.tf` - Deployment outputs
   - `infra/terraform.tfvars.example` - Example variable values

2. **Terraform Modules**
   - `infra/modules/identity/` - User-assigned managed identities (3)
   - `infra/modules/monitoring/` - Application Insights + Log Analytics
   - `infra/modules/networking/` - VNet with subnets (optional)
   - `infra/modules/database/` - Azure SQL Server + Database
   - `infra/modules/app_service/` - App Service Plans, Apps, Key Vault

3. **Azure Developer CLI**
   - `azure.yaml` - Service definitions for azd deployment

4. **Documentation**
   - `infra/README.md` - Complete deployment instructions

### Infrastructure Resources

The Terraform configuration will create:

| Resource Type | Count | Purpose |
|--------------|-------|---------|
| Resource Group | 1 | Container for all resources |
| User-Assigned Managed Identity | 3 | Secure authentication (web, api, spa) |
| Log Analytics Workspace | 1 | Centralized logging |
| Application Insights | 1 | Application performance monitoring |
| VNet + Subnets | 1 | Private networking (optional) |
| Azure SQL Server | 1 | Database server with Entra ID admin |
| SQL Database | 1 | S1 tier (20 DTUs, 250GB max) |
| Key Vault | 1 | Secret management with RBAC |
| App Service Plan | 3 | Compute for web, api, spa apps |
| App Service | 3 | Hosting for applications |
| Firewall Rules | 1+ | Database security |
| RBAC Assignments | 3 | Identity permissions for Key Vault |

**Total Resources**: ~20-25 Azure resources

### Security Features

 **Managed Identities**: Apps authenticate using managed identities, not connection strings
 **Key Vault Integration**: Database credentials stored in Key Vault
 **RBAC Authorization**: Least-privilege access for each identity
 **TLS 1.2 Minimum**: Enforced on SQL Server
 **HTTPS Only**: All App Services require HTTPS
 **Threat Detection**: Enabled on SQL Database
 **SQL Auditing**: 30-day retention policy
 **Optional Private Endpoints**: For production deployments

### Cost Estimate

| Service | SKU | Monthly Cost |
|---------|-----|-------------|
| Web App Service Plan | B2 (2 core, 3.5GB) | ~$35 |
| API App Service Plan | B2 (2 core, 3.5GB) | ~$35 |
| SPA App Service Plan | B1 (1 core, 1.75GB) | ~$13 |
| SQL Database | S1 (20 DTUs) | ~$30 |
| Application Insights | Pay-as-you-go | ~$5-10 |
| Key Vault | Standard | ~$1-2 |
| **Total** | | **~$117-147/month** |

## Installation Prerequisites

### 1. Install Azure CLI

Windows (PowerShell):
```powershell
winget install Microsoft.AzureCLI
```

Verify installation:
```powershell
az --version
az login
```

### 2. Install Terraform

Windows (PowerShell):
```powershell
# Using Chocolatey
choco install terraform

# Or download from https://www.terraform.io/downloads
```

Verify installation:
```powershell
terraform version  # Should be 1.5.0 or higher
```

### 3. Install .NET 8.0 SDK

Download from https://dotnet.microsoft.com/download/dotnet/8.0

Verify:
```powershell
dotnet --version  # Should be 8.0.x
```

### 4. Install Azure Developer CLI (Optional)

```powershell
winget install Microsoft.Azd
```

## Deployment Options

### Option A: Terraform Deployment (Recommended)

1. **Configure Variables**
   ```powershell
   cd infra
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Initialize Terraform**
   ```powershell
   terraform init
   ```

3. **Review Plan**
   ```powershell
   terraform plan -out=tfplan
   ```

4. **Deploy Infrastructure**
   ```powershell
   terraform apply tfplan
   ```

5. **Initialize Database**
   ```powershell
   cd ../ContosoUniversity.Data
   dotnet ef database update --context SchoolContext
   dotnet ef database update --context ApplicationDbContext
   dotnet ef database update --context IdentityContext
   ```

6. **Deploy Applications**
   ```powershell
   # Web App
   cd ../ContosoUniversity.Web
   dotnet publish -c Release
   az webapp deploy --name <web-app-name> --resource-group <rg-name> --src-path ./bin/Release/net8.0/publish

   # API
   cd ../ContosoUniversity.Api
   dotnet publish -c Release
   az webapp deploy --name <api-app-name> --resource-group <rg-name> --src-path ./bin/Release/net8.0/publish

   # SPA
   cd ../ContosoUniversity.Spa.React
   dotnet publish -c Release
   az webapp deploy --name <spa-app-name> --resource-group <rg-name> --src-path ./bin/Release/net8.0/publish
   ```

### Option B: Azure Developer CLI

```powershell
azd init
azd up
```

## Post-Deployment Configuration

### 1. Verify Managed Identity Access

```powershell
# Check SQL Server Entra ID admin
az sql server ad-admin list --resource-group rg-contosouniversity-dev --server-name <sql-server-name>

# Test Key Vault access from portal or app
```

### 2. Configure Application Settings

Check App Service configuration includes:
- `APPLICATIONINSIGHTS_CONNECTION_STRING`
- `KeyVaultName`
- `ASPNETCORE_ENVIRONMENT=Production`
- Connection string referencing Key Vault secret

### 3. Test Applications

```powershell
# Get URLs from Terraform outputs
terraform output web_app_url
terraform output api_app_url
terraform output spa_app_url

# Open in browser
Start-Process "https://app-web-contosouniversity-dev.azurewebsites.net"
```

## Migration Status

###  Completed Phases

- **Phase 1-2**: Assessment complete (AppCat analysis with 13 incidents)
- **Phase 3**: Data layer migrated to .NET 8.0 and EF Core 8.0
- **Phase 4**: Infrastructure as Code generation complete

###  Pending Phases

- **Phase 5**: Deploy infrastructure and applications to Azure
- **Phase 6**: Testing and validation (functional, integration, performance)
- **Phase 7**: CI/CD pipeline setup
- **Phase 8**: Monitoring and optimization

## Troubleshooting

### Terraform Issues

**Error: "Key Vault name already exists"**
- Key Vault has soft-delete enabled. Purge the deleted vault:
  ```powershell
  az keyvault purge --name <vault-name>
  ```

**Error: "SQL Server name not unique"**
- The random suffix should prevent this. If it occurs, manually modify in tfvars.

### Database Connection Issues

**Error: "Login failed for user"**
- Verify managed identity is configured as Entra ID admin
- Check firewall rules allow Azure services
- RBAC permissions may take 5-10 minutes to propagate

### Application Issues

**Error: "Cannot access Key Vault"**
- Verify managed identity has "Key Vault Secrets User" role
- Check identity is assigned to App Service
- Validate Key Vault reference syntax in connection strings

**Error: Database migrations not applied**
- Run migrations manually using connection string
- Check SQL Database firewall allows your IP

## Next Steps

1.  **Phase 4 Complete**: Infrastructure code generated
2. **Phase 5**: Deploy infrastructure using `terraform apply`
3. **Phase 6**: Run integration tests
4. **Phase 7**: Set up CI/CD pipeline (GitHub Actions or Azure DevOps)
5. **Phase 8**: Configure monitoring alerts and dashboards

## Support Resources

- **Terraform Documentation**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **Azure App Service**: https://learn.microsoft.com/azure/app-service/
- **Managed Identities**: https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/
- **Key Vault**: https://learn.microsoft.com/azure/key-vault/
- **Application Insights**: https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview

---

**Generated**: 2025-12-11 13:52:53
**Migration Project**: ContosoUniversity .NET 2.1  .NET 8.0
**Target Platform**: Azure App Service (PaaS)
