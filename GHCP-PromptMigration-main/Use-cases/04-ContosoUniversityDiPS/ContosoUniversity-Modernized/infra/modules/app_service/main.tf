# App Service Module - 3 App Services with Key Vault

variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "naming_suffix" { type = string }
variable "owner" { type = string }
variable "environment" { type = string }
variable "web_identity_id" { type = string }
variable "web_identity_principal_id" { type = string }
variable "api_identity_id" { type = string }
variable "api_identity_principal_id" { type = string }
variable "spa_identity_id" { type = string }
variable "spa_identity_principal_id" { type = string }
variable "instrumentation_key" { 
  type = string
  sensitive = true
}
variable "app_insights_connection_string" { 
  type = string
  sensitive = true
}
variable "database_connection_string" { 
  type = string
  sensitive = true
}
variable "sql_server_fqdn" { type = string }
variable "database_name" { type = string }
variable "web_sku" { 
  type = string
  default = "B2"
}
variable "api_sku" { 
  type = string
  default = "B2"
}
variable "spa_sku" { 
  type = string
  default = "B1"
}
variable "subnet_id" { 
  type = string
  default = null
}
variable "enable_vnet_integration" { 
  type = bool
  default = false
}
variable "tags" { 
  type = map(string)
  default = {}
}

data "azurerm_client_config" "current" {}

# Random suffix for Key Vault name
resource "random_string" "kv_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Azure Key Vault (name limited to 3-24 alphanumeric chars and dashes)
# Using abbreviated name: kv-cu-<owner>-<random> to meet 24 char limit
resource "azurerm_key_vault" "main" {
  name                       = "kv-cu-${var.owner}-${random_string.kv_suffix.result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization  = true
  
  tags = var.tags
}

# RBAC for Terraform Service Principal (current user) to manage secrets
# Commented out - role assignment already exists in Azure
# resource "azurerm_role_assignment" "terraform_kv_admin" {
#   scope                = azurerm_key_vault.main.id
#   role_definition_name = "Key Vault Secrets Officer"
#   principal_id         = data.azurerm_client_config.current.object_id
# }

# RBAC for Web App Identity
resource "azurerm_role_assignment" "web_kv_secrets" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.web_identity_principal_id
}

# RBAC for API Identity
resource "azurerm_role_assignment" "api_kv_secrets" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.api_identity_principal_id
}

# RBAC for SPA Identity
resource "azurerm_role_assignment" "spa_kv_secrets" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.spa_identity_principal_id
}

# Store database connection string in Key Vault
resource "azurerm_key_vault_secret" "db_connection" {
  name         = "DatabaseConnectionString"
  value        = var.database_connection_string
  key_vault_id = azurerm_key_vault.main.id
  
  depends_on = [
    azurerm_role_assignment.web_kv_secrets,
    azurerm_role_assignment.api_kv_secrets,
    azurerm_role_assignment.spa_kv_secrets
  ]
}

# App Service Plan for Web
resource "azurerm_service_plan" "web" {
  name                = "asp-${var.naming_suffix}-web"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  sku_name            = var.web_sku
  
  tags = var.tags
}

# App Service Plan for API
resource "azurerm_service_plan" "api" {
  name                = "asp-${var.naming_suffix}-api"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  sku_name            = var.api_sku
  
  tags = var.tags
}

# App Service Plan for SPA
resource "azurerm_service_plan" "spa" {
  name                = "asp-${var.naming_suffix}-spa"
  resource_group_name = var.resource_group_name
  location            = var.location
  os_type             = "Windows"
  sku_name            = var.spa_sku
  
  tags = var.tags
}

# Web App Service
resource "azurerm_windows_web_app" "web" {
  name                = "app-${var.naming_suffix}-web"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.web.id
  https_only          = true
  
  identity {
    type         = "UserAssigned"
    identity_ids = [var.web_identity_id]
  }
  
  site_config {
    always_on = true
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v8.0"
    }
  }
  
  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "KeyVaultName" = azurerm_key_vault.main.name
  }
  
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_connection.id})"
  }
  
  tags = var.tags
}

# API App Service
resource "azurerm_windows_web_app" "api" {
  name                = "app-${var.naming_suffix}-api"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.api.id
  https_only          = true
  
  identity {
    type         = "UserAssigned"
    identity_ids = [var.api_identity_id]
  }
  
  site_config {
    always_on = true
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v8.0"
    }
    cors {
      allowed_origins = ["https://app-${var.naming_suffix}-spa.azurewebsites.net"]
      support_credentials = true
    }
  }
  
  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "KeyVaultName" = azurerm_key_vault.main.name
  }
  
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_connection.id})"
  }
  
  tags = var.tags
}

# SPA App Service
resource "azurerm_windows_web_app" "spa" {
  name                = "app-${var.naming_suffix}-spa"
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = azurerm_service_plan.spa.id
  https_only          = true
  
  identity {
    type         = "UserAssigned"
    identity_ids = [var.spa_identity_id]
  }
  
  site_config {
    always_on = true
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v8.0"
    }
  }
  
  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "ASPNETCORE_ENVIRONMENT" = "Production"
    "KeyVaultName" = azurerm_key_vault.main.name
    "ApiBaseUrl" = "https://app-${var.naming_suffix}-api.azurewebsites.net"
  }
  
  connection_string {
    name  = "DefaultConnection"
    type  = "SQLAzure"
    value = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.db_connection.id})"
  }
  
  tags = var.tags
}

# VNet integration if enabled
resource "azurerm_app_service_virtual_network_swift_connection" "web" {
  count          = var.enable_vnet_integration ? 1 : 0
  app_service_id = azurerm_windows_web_app.web.id
  subnet_id      = var.subnet_id
}

resource "azurerm_app_service_virtual_network_swift_connection" "api" {
  count          = var.enable_vnet_integration ? 1 : 0
  app_service_id = azurerm_windows_web_app.api.id
  subnet_id      = var.subnet_id
}

resource "azurerm_app_service_virtual_network_swift_connection" "spa" {
  count          = var.enable_vnet_integration ? 1 : 0
  app_service_id = azurerm_windows_web_app.spa.id
  subnet_id      = var.subnet_id
}

output "key_vault_id" { value = azurerm_key_vault.main.id }
output "key_vault_name" { value = azurerm_key_vault.main.name }
output "web_app_name" { value = azurerm_windows_web_app.web.name }
output "web_app_url" { value = "https://${azurerm_windows_web_app.web.default_hostname}" }
output "api_app_name" { value = azurerm_windows_web_app.api.name }
output "api_app_url" { value = "https://${azurerm_windows_web_app.api.default_hostname}" }
output "spa_app_name" { value = azurerm_windows_web_app.spa.name }
output "spa_app_url" { value = "https://${azurerm_windows_web_app.spa.default_hostname}" }
