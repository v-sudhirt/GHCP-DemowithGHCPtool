# Phase 5: Azure Deployment Guide
**Generated**: 2025-12-11 15:55:46
**Subscription**: Service 360 Test (8cff5c8a-98f3-44ad-b300-2d44716c802c)

## Deployment Status: READY TO DEPLOY

### Prerequisites Check 
- [x] Azure CLI installed and authenticated
- [x] Azure Developer CLI (azd) installed (v1.21.3)
- [x] Subscription configured: Service 360 Test
- [x] Entra ID credentials configured
- [x] terraform.tfvars file created
- [x] azure.yaml configuration present
- [ ] Terraform installed (REQUIRED for infrastructure deployment)

### Configuration Summary

**Azure Environment:**
- Subscription: Service 360 Test
- Subscription ID: 8cff5c8a-98f3-44ad-b300-2d44716c802c
- Environment: dev
- Location: eastus
- Entra ID Admin: v-sudhirt@microsoft.com (4336179d-a982-4af9-bf7a-0f484dd0e0a5)

**Infrastructure Resources:**
- 3 App Services (Web, API, SPA)
- Azure SQL Database (S1 tier, 20 DTUs)
- Application Insights (MANDATORY - 90-day retention)
- Key Vault for secrets
- 3 Managed Identities
- Log Analytics Workspace

**Estimated Monthly Cost:** $117-147

##  CRITICAL: Install Terraform First

Before proceeding with deployment, Terraform must be installed.

### Option 1: Install via Chocolatey (Recommended)
```powershell
# Install Chocolatey if not already installed
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebRequest 'https://community.chocolatey.org/install.ps1')).DownloadString()

# Install Terraform
choco install terraform -y

# Verify installation
terraform version
```

### Option 2: Install via winget
```powershell
winget install HashiCorp.Terraform
```

### Option 3: Manual Download
1. Download from: https://www.terraform.io/downloads
2. Extract to a folder (e.g., C:\terraform)
3. Add to PATH environment variable
4. Verify: `terraform version`

## Deployment Steps

### Step 1: Initialize Terraform

```powershell
cd infra
terraform init
```

**Expected Output:**
- Downloads azurerm provider (~3.80)
- Downloads azuread provider (~2.45)
- Downloads random provider (~3.5)
- Initializes backend (local)

### Step 2: Validate Configuration

```powershell
terraform validate
```

**Expected Output:**
```
Success! The configuration is valid.
```

### Step 3: Review Deployment Plan

```powershell
terraform plan -out=tfplan
```

**This will show:**
- ~20-25 resources to be created
- Resource Group
- 3 User-Assigned Managed Identities
- Log Analytics Workspace + Application Insights
- Azure SQL Server + Database
- 3 App Service Plans + App Services
- Key Vault with secrets
- RBAC assignments

**Review carefully for:**
- Correct subscription ID
- Proper naming conventions
- Security configurations
- Cost implications

### Step 4: Deploy Infrastructure

```powershell
terraform apply tfplan
```

**Duration:** ~10-15 minutes

**Resources Created:**
1. Resource Group: rg-contosouniversity-dev-eastus
2. Managed Identities: uami-web/api/spa-contosouniversity-dev
3. Log Analytics: log-contosouniversity-dev
4. Application Insights: appi-contosouniversity-dev (MANDATORY)
5. SQL Server: sql-contosouniversity-dev-[random]
6. SQL Database: sqldb-contosouniversity-dev
7. Key Vault: kv-contosouniversity-dev-[random]
8. App Service Plans: asp-web/api/spa-contosouniversity-dev
9. App Services: app-web/api/spa-contosouniversity-dev

### Step 5: Capture Outputs

```powershell
terraform output -json | ConvertFrom-Json | ConvertTo-Json -Depth 10 > deployment-outputs.json
terraform output
```

**Important Outputs:**
- `web_app_url`: Web application URL
- `api_app_url`: API endpoint URL
- `spa_app_url`: SPA application URL
- `sql_server_fqdn`: Database server FQDN
- `key_vault_name`: Key Vault name

### Step 6: Initialize Database

After infrastructure is deployed, run EF Core migrations:

```powershell
cd ../ContosoUniversity.Data

# Get connection string from terraform output
$sqlServer = terraform output -raw sql_server_fqdn
$dbName = terraform output -raw database_name

# Run migrations for each DbContext
dotnet ef database update --context SchoolContext
dotnet ef database update --context ApplicationDbContext
dotnet ef database update --context IdentityContext
dotnet ef database update --context BlogContext
```

### Step 7: Deploy Application Code

**Option A: Using Azure CLI**

```powershell
# Build and publish Web app
cd ../ContosoUniversity.Web
dotnet publish -c Release -o ./publish
Compress-Archive -Path ./publish/* -DestinationPath ./publish.zip -Force
az webapp deploy --name (terraform output -raw web_app_name) --resource-group (terraform output -raw resource_group_name) --src-path ./publish.zip --type zip

# Build and publish API
cd ../ContosoUniversity.Api
dotnet publish -c Release -o ./publish
Compress-Archive -Path ./publish/* -DestinationPath ./publish.zip -Force
az webapp deploy --name (terraform output -raw api_app_name) --resource-group (terraform output -raw resource_group_name) --src-path ./publish.zip --type zip

# Build and publish SPA
cd ../ContosoUniversity.Spa.React
dotnet publish -c Release -o ./publish
Compress-Archive -Path ./publish/* -DestinationPath ./publish.zip -Force
az webapp deploy --name (terraform output -raw spa_app_name) --resource-group (terraform output -raw resource_group_name) --src-path ./publish.zip --type zip
```

**Option B: Using Azure Developer CLI**

```powershell
cd ..
azd init
azd deploy
```

## Post-Deployment Verification

### 1. Verify Infrastructure

```powershell
# Check resource group
az group show --name rg-contosouniversity-dev-eastus --query "{Name:name, Location:location, ProvisioningState:properties.provisioningState}" -o table

# Check App Services
az webapp list --resource-group rg-contosouniversity-dev-eastus --query "[].{Name:name, State:state, DefaultHostName:defaultHostName}" -o table

# Check SQL Database
az sql db show --resource-group rg-contosouniversity-dev-eastus --server sql-contosouniversity-dev-* --name sqldb-contosouniversity-dev --query "{Name:name, Status:status, ServiceObjective:currentServiceObjectiveName}" -o table

# Check Application Insights (MANDATORY)
az monitor app-insights component show --resource-group rg-contosouniversity-dev-eastus --app appi-contosouniversity-dev --query "{Name:name, ProvisioningState:provisioningState, InstrumentationKey:instrumentationKey}" -o table
```

### 2. Test Applications

```powershell
# Get application URLs
$webUrl = terraform output -raw web_app_url
$apiUrl = terraform output -raw api_app_url
$spaUrl = terraform output -raw spa_app_url

# Open in browser
Start-Process $webUrl
Start-Process $apiUrl/swagger
Start-Process $spaUrl
```

### 3. Verify Application Insights Integration

```powershell
# Check Application Insights is receiving telemetry
az monitor app-insights query --app appi-contosouniversity-dev --resource-group rg-contosouniversity-dev-eastus --analytics-query "requests | take 10" --offset 30m
```

### 4. Check Database Connectivity

Test that applications can connect to Azure SQL Database using managed identity authentication.

### 5. Verify Key Vault Access

Ensure all managed identities have proper access to Key Vault secrets.

## Troubleshooting

### Issue: Terraform not installed
**Solution:** Follow installation steps above (Option 1, 2, or 3)

### Issue: SQL Server name already exists
**Solution:** The random suffix should prevent this. If it occurs, run `terraform destroy` and redeploy.

### Issue: Key Vault name already exists
**Solution:** Purge soft-deleted vault:
```powershell
az keyvault purge --name kv-contosouniversity-dev-*
```

### Issue: Managed Identity cannot access Key Vault
**Solution:** RBAC permissions may take 5-10 minutes to propagate. Wait and retry.

### Issue: Database connection fails
**Solution:** 
1. Check firewall rules allow Azure services
2. Verify managed identity has SQL permissions
3. Check connection string format in app settings

### Issue: Application Insights not receiving data
**Solution:**
1. Verify instrumentation key is configured in app settings
2. Check that Application Insights agent is enabled
3. Wait 2-3 minutes for telemetry to appear

## Monitoring and Health Checks

### Application Insights Queries

```kql
// Request count
requests 
| summarize count() by bin(timestamp, 5m)

// Failed requests
requests 
| where success == false
| project timestamp, name, resultCode, duration

// Performance
requests 
| summarize avg(duration), percentile(duration, 95) by name
```

### Set Up Alerts

```powershell
# Create alert for high error rate
az monitor metrics alert create --name "High Error Rate" --resource-group rg-contosouniversity-dev-eastus --scopes (terraform output -raw app_insights_id) --condition "count requests/failed > 10" --window-size 5m --evaluation-frequency 1m
```

## Cost Management

### View Current Costs

```powershell
az consumption usage list --start-date (Get-Date).AddDays(-7).ToString("yyyy-MM-dd") --end-date (Get-Date).ToString("yyyy-MM-dd") | ConvertFrom-Json | Where-Object {$_.instanceName -like "*contosouniversity*"} | Select-Object instanceName, usageQuantity, cost
```

### Cost Optimization Recommendations
1. Scale down App Service Plans during off-hours
2. Use Azure SQL elastic pools if multiple databases
3. Review Application Insights data retention (current: 90 days)
4. Enable auto-shutdown for dev environment
5. Use Azure Reservations for long-term resources

## Next Steps

###  Completed
- Phase 1-2: Assessment complete
- Phase 3: Data layer migrated (20% code migration)
- Phase 4: Infrastructure code generated
- Phase 5: Deployment configuration ready

###  Pending
1. **Install Terraform** (REQUIRED)
2. **Deploy infrastructure** using terraform apply
3. **Phase 6: Testing and Validation**
   - Unit tests
   - Integration tests
   - Performance tests
   - Security validation
4. **Phase 7: CI/CD Pipeline Setup**
   - Use command: `/phase6-setupcicd`
   - GitHub Actions or Azure DevOps
5. **Phase 8: Monitoring and Optimization**
   - Configure alerts
   - Set up dashboards
   - Performance tuning

## Support and Resources

- **Terraform Documentation**: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
- **Azure App Service**: https://learn.microsoft.com/azure/app-service/
- **Application Insights**: https://learn.microsoft.com/azure/azure-monitor/app/app-insights-overview
- **Azure SQL Database**: https://learn.microsoft.com/azure/azure-sql/database/
- **Managed Identities**: https://learn.microsoft.com/azure/active-directory/managed-identities-azure-resources/

---

**Deployment Timeline:**
- Terraform Installation: ~5 minutes
- Infrastructure Deployment: ~10-15 minutes
- Database Initialization: ~2-3 minutes
- Application Deployment: ~5-10 minutes per app
- **Total**: ~30-45 minutes

**Security Notes:**
-  All secrets stored in Key Vault
-  Managed identities for authentication
-  Application Insights MANDATORY for all apps
-  TLS 1.2 enforced on SQL Server
-  HTTPS only on App Services
-  Threat detection enabled
-  SQL auditing (30-day retention)

**Generated**: 2025-12-11 15:55:46
