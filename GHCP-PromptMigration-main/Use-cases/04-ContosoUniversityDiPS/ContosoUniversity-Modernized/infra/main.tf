# Terraform configuration for ContosoUniversity Azure deployment
# Generated: 2025-12-11 13:38:54

terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.45"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Backend configuration for remote state
  # Uncomment and configure after creating storage account
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "sttfstate<uniqueid>"
  #   container_name       = "tfstate"
  #   key                  = "contosouniversity.tfstate"
  # }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {
}

# Data sources
data "azurerm_client_config" "current" {}

# Local variables for naming and tagging
locals {
  environment = var.environment
  location    = var.location
  project     = var.project
  service     = var.service
  owner       = var.owner
  
  # Resource naming convention: <resource-type>-<project>-<service>-<location>-<owner>-<environment>
  # Example: rg-infra-contosouniv-westus-sudhirt-demopoc
  naming_suffix = "${local.project}-${local.service}-${local.location}-${local.owner}-${local.environment}"
  
  # Common tags applied to all resources
  common_tags = merge(var.tags, {
    Environment = local.environment
    Project     = local.project
    ManagedBy   = "Terraform"
    DeployDate  = timestamp()
  })
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${local.naming_suffix}"
  location = local.location
  tags     = local.common_tags
}

# Managed Identity for applications
module "identity" {
  source = "./modules/identity"
  
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  naming_suffix       = local.naming_suffix
  tags                = local.common_tags
}

# Networking (optional - for private endpoints)
module "networking" {
  source = "./modules/networking"
  
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  naming_suffix       = local.naming_suffix
  enable_private_endpoints = var.enable_private_endpoints
  tags                = local.common_tags
}

# Monitoring (Application Insights & Log Analytics) - MANDATORY
module "monitoring" {
  source = "./modules/monitoring"
  
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  naming_suffix       = local.naming_suffix
  retention_days      = var.app_insights_retention_days
  daily_data_cap_gb   = var.app_insights_daily_cap_gb
  tags                = local.common_tags
}

# Azure SQL Database with Entra ID Authentication
module "database" {
  source = "./modules/database"
  
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  naming_suffix           = local.naming_suffix
  admin_login             = var.sql_admin_login
  admin_password          = var.sql_admin_password
  enable_entra_admin      = true
  entra_admin_object_id   = var.entra_admin_object_id
  entra_admin_login       = var.entra_admin_login
  tenant_id               = var.tenant_id
  subnet_id               = module.networking.database_subnet_id
  enable_private_endpoint = var.enable_private_endpoints
  tags                    = local.common_tags
  
  depends_on = [module.networking]
}

# App Service Plans and Apps
module "app_service" {
  source = "./modules/app_service"
  
  resource_group_name           = azurerm_resource_group.main.name
  location                      = azurerm_resource_group.main.location
  naming_suffix                 = local.naming_suffix
  owner                         = local.owner
  environment                   = local.environment
  
  # Managed Identity
  web_identity_id               = module.identity.web_app_identity_id
  web_identity_principal_id     = module.identity.web_app_identity_principal_id
  api_identity_id               = module.identity.api_app_identity_id
  api_identity_principal_id     = module.identity.api_app_identity_principal_id
  spa_identity_id               = module.identity.spa_app_identity_id
  spa_identity_principal_id     = module.identity.spa_app_identity_principal_id
  
  # Monitoring
  instrumentation_key                    = module.monitoring.instrumentation_key
  app_insights_connection_string         = module.monitoring.connection_string
  
  # Database
  sql_server_fqdn               = module.database.sql_server_fqdn
  database_name                 = module.database.database_name
  database_connection_string    = module.database.connection_string
  
  # App Service SKUs
  web_sku                       = var.web_app_sku
  api_sku                       = var.api_app_sku
  spa_sku                       = var.spa_app_sku
  
  # Networking
  subnet_id                     = module.networking.app_service_subnet_id
  enable_vnet_integration       = var.enable_private_endpoints
  
  tags                          = local.common_tags
  
  depends_on = [
    module.identity,
    module.monitoring,
    module.database
  ]
}
