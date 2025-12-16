# ContosoUniversity Infrastructure as Code

This directory contains Terraform configuration for deploying the ContosoUniversity application to Azure App Service.

## Architecture

The infrastructure includes:
- **3 Azure App Services**: Web MVC, REST API, React SPA
- **3 App Service Plans**: Separate plans for independent scaling
- **Azure SQL Database**: S1 tier (20 DTUs) with Entra ID authentication
- **Azure Key Vault**: Centralized secret management with RBAC
- **User-Assigned Managed Identities**: One per application for secure authentication
- **Application Insights**: APM with Log Analytics Workspace
- **Optional VNet**: Private networking with service endpoints and VNet integration

## Prerequisites

1. **Azure CLI** (version 2.50+)
   ```powershell
   az --version
   ```

2. **Terraform** (version 1.5+)
   ```powershell
   terraform version
   ```

3. **Azure Subscription**
   ```powershell
   az login
   az account set --subscription "YOUR_SUBSCRIPTION_ID"
   ```

4. **Get your Entra ID Object ID**
   ```powershell
   az ad user show --id your-email@domain.com --query id -o tsv
   ```

## Cost Estimate

- **App Services**: ~$70-90/month (3 instances: B2 + B2 + B1)
- **SQL Database S1**: ~$30/month (20 DTUs)
- **Application Insights**: ~$5-10/month (basic monitoring)
- **Key Vault**: ~$1-2/month
- **Total**: ~$117-147/month

## Deployment Steps

### 1. Configure Variables

Copy the example file and customize:
```powershell
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
```hcl
environment = "dev"
location = "eastus"
sql_admin_login = "sqladmin"
sql_admin_password = "YourSecurePassword123!"
entra_admin_object_id = "YOUR-OBJECT-ID-HERE"
entra_admin_login = "your-email@domain.com"
```

### 2. Configure Backend Storage (Recommended)

Create Azure Storage for Terraform state:
```powershell
# Create resource group for Terraform state
az group create --name rg-terraform-state --location eastus

# Create storage account (name must be globally unique)
az storage account create \
  --name tfstatecontoso`1892 \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS

# Create container
az storage container create \
  --name tfstate \
  --account-name YOUR_STORAGE_ACCOUNT_NAME
```

Uncomment and configure the backend block in `main.tf`:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "tfstatecontoso1234"
    container_name       = "tfstate"
    key                  = "contosouniversity.tfstate"
  }
}
```

### 3. Initialize Terraform

```powershell
terraform init
```

### 4. Review Deployment Plan

```powershell
terraform plan -out=tfplan
```

Review the resources to be created:
- 3 User-Assigned Managed Identities
- 1 Log Analytics Workspace
- 1 Application Insights
- 1 Azure SQL Server + Database
- 3 App Service Plans
- 3 App Services
- 1 Key Vault with secrets
- Security configurations (firewall, RBAC)

### 5. Deploy Infrastructure

```powershell
terraform apply tfplan
```

This takes approximately 5-10 minutes. Note the outputs:
- Web App URL
- API App URL
- SPA App URL
- SQL Server FQDN
- Key Vault name

### 6. Initialize Database

After deployment, run EF Core migrations:
```powershell
# Set connection string (from Terraform outputs)
$env:ConnectionStrings__DefaultConnection = "Server=tcp:YOUR-SQL-SERVER.database.windows.net,1433;Database=sqldb-contosouniversity;Authentication=Active Directory Managed Identity;Encrypt=True;"

# Run migrations for each DbContext
cd ../ContosoUniversity.Data
dotnet ef database update --context SchoolContext
dotnet ef database update --context ApplicationDbContext
dotnet ef database update --context IdentityContext
```

### 7. Deploy Application Code

Using Azure CLI:
```powershell
# Build and deploy Web app
cd ../ContosoUniversity.Web
dotnet publish -c Release -o ./publish
az webapp deploy --name app-web-contosouniversity-dev --resource-group rg-contosouniversity-dev --src-path ./publish.zip --type zip

# Build and deploy API
cd ../ContosoUniversity.Api
dotnet publish -c Release -o ./publish
az webapp deploy --name app-api-contosouniversity-dev --resource-group rg-contosouniversity-dev --src-path ./publish.zip --type zip

# Build and deploy SPA
cd ../ContosoUniversity.Spa.React
dotnet publish -c Release -o ./publish
az webapp deploy --name app-spa-contosouniversity-dev --resource-group rg-contosouniversity-dev --src-path ./publish.zip --type zip
```

Or using Azure Developer CLI (azd):
```powershell
cd ..
azd deploy
```

## Module Structure

- `modules/identity/` - User-assigned managed identities (3)
- `modules/monitoring/` - Application Insights + Log Analytics
- `modules/networking/` - Optional VNet with subnets
- `modules/database/` - Azure SQL Server + Database
- `modules/app_service/` - App Service Plans, Apps, Key Vault

## Security Features

 **Managed Identities**: No connection strings in app settings
 **Key Vault**: Database credentials stored securely
 **RBAC**: Least-privilege access for each identity
 **TLS 1.2**: Enforced on SQL Server
 **HTTPS Only**: All App Services require HTTPS
 **Threat Detection**: Enabled on SQL Database
 **Auditing**: 30-day retention on SQL operations
 **Optional Private Endpoints**: For production environments

## Outputs

After successful deployment:

```powershell
terraform output web_app_url          # https://app-web-contosouniversity-dev.azurewebsites.net
terraform output api_app_url          # https://app-api-contosouniversity-dev.azurewebsites.net
terraform output spa_app_url          # https://app-spa-contosouniversity-dev.azurewebsites.net
terraform output sql_server_fqdn      # sql-contosouniversity-dev-abc123.database.windows.net
terraform output key_vault_name       # kv-contosouniversity-dev-xyz789
```

## Cleanup

To destroy all resources:
```powershell
terraform destroy
```

 This is irreversible and will delete all data!

## Troubleshooting

**Issue**: "Key Vault name already exists"
- Solution: Key Vault has soft-delete. Purge or wait 7 days:
  ```powershell
  az keyvault purge --name kv-contosouniversity-dev-xyz789
  ```

**Issue**: "SQL Server name already taken"
- Solution: Name must be globally unique. The random suffix should prevent this.

**Issue**: "Managed Identity cannot access Key Vault"
- Solution: RBAC permissions take ~5 minutes to propagate. Wait and retry.

**Issue**: Database connection fails
- Solution: Ensure firewall allows Azure services and managed identity has permissions:
  ```powershell
  az sql server ad-admin list --resource-group rg-contosouniversity-dev --server-name YOUR-SQL-SERVER
  ```

## Next Steps

1. Configure CI/CD pipeline (Azure DevOps or GitHub Actions)
2. Enable private endpoints for production
3. Configure custom domains and SSL certificates
4. Set up Azure Front Door for global distribution
5. Enable backup and disaster recovery

## Support

For issues with:
- Infrastructure: Check Terraform logs and Azure Portal
- Application: Check Application Insights and App Service logs
- Database: Check SQL Database query performance insights
