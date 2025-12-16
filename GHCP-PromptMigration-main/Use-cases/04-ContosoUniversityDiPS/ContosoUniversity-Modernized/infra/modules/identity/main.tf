# Identity Module - Managed Identities for ContosoUniversity applications

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "naming_suffix" {
  description = "Naming suffix for resources (project-service-location-owner-environment)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# Managed Identity for Web App
resource "azurerm_user_assigned_identity" "web_app" {
  name                = "id-${var.naming_suffix}-web"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Managed Identity for API App
resource "azurerm_user_assigned_identity" "api_app" {
  name                = "id-${var.naming_suffix}-api"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Managed Identity for SPA App
resource "azurerm_user_assigned_identity" "spa_app" {
  name                = "id-${var.naming_suffix}-spa"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

# Outputs
output "web_app_identity_id" {
  description = "ID of the Web App managed identity"
  value       = azurerm_user_assigned_identity.web_app.id
}

output "web_app_identity_principal_id" {
  description = "Principal ID of the Web App managed identity"
  value       = azurerm_user_assigned_identity.web_app.principal_id
}

output "web_app_identity_client_id" {
  description = "Client ID of the Web App managed identity"
  value       = azurerm_user_assigned_identity.web_app.client_id
}

output "api_app_identity_id" {
  description = "ID of the API App managed identity"
  value       = azurerm_user_assigned_identity.api_app.id
}

output "api_app_identity_principal_id" {
  description = "Principal ID of the API App managed identity"
  value       = azurerm_user_assigned_identity.api_app.principal_id
}

output "api_app_identity_client_id" {
  description = "Client ID of the API App managed identity"
  value       = azurerm_user_assigned_identity.api_app.client_id
}

output "spa_app_identity_id" {
  description = "ID of the SPA App managed identity"
  value       = azurerm_user_assigned_identity.spa_app.id
}

output "spa_app_identity_principal_id" {
  description = "Principal ID of the SPA App managed identity"
  value       = azurerm_user_assigned_identity.spa_app.principal_id
}

output "spa_app_identity_client_id" {
  description = "Client ID of the SPA App managed identity"
  value       = azurerm_user_assigned_identity.spa_app.client_id
}
