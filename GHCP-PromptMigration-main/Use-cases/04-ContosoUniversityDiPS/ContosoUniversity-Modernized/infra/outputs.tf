# Outputs for ContosoUniversity deployment

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "web_app_url" {
  description = "URL of the Web application"
  value       = module.app_service.web_app_url
}

output "api_app_url" {
  description = "URL of the API application"
  value       = module.app_service.api_app_url
}

output "spa_app_url" {
  description = "URL of the SPA application"
  value       = module.app_service.spa_app_url
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = module.database.sql_server_fqdn
}

output "database_name" {
  description = "Name of the SQL Database"
  value       = module.database.database_name
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.app_service.key_vault_name
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = module.monitoring.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.monitoring.connection_string
  sensitive   = true
}

output "web_app_identity_principal_id" {
  description = "Principal ID of the Web App managed identity"
  value       = module.identity.web_app_identity_principal_id
}

output "api_app_identity_principal_id" {
  description = "Principal ID of the API App managed identity"
  value       = module.identity.api_app_identity_principal_id
}

output "spa_app_identity_principal_id" {
  description = "Principal ID of the SPA App managed identity"
  value       = module.identity.spa_app_identity_principal_id
}
