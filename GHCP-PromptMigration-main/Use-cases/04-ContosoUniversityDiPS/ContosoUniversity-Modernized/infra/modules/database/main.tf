# Database Module - Azure SQL Database
# Using existing SQL Server: sql-contosounversity-sudhirt

variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "naming_suffix" { type = string }
variable "tenant_id" { 
  type = string
  description = "Azure AD Tenant ID for Entra authentication"
}
variable "admin_login" { 
  type = string
  sensitive = true
}
variable "admin_password" { 
  type = string
  sensitive = true
}
variable "enable_entra_admin" { 
  type = bool
  default = true
}
variable "entra_admin_object_id" { 
  type = string
  default = ""
}
variable "entra_admin_login" { 
  type = string
  default = ""
}
variable "subnet_id" { 
  type = string
  default = null
}
variable "enable_private_endpoint" { 
  type = bool
  default = false
}
variable "tags" { 
  type = map(string)
  default = {}
}

# Data source to reference existing SQL Server
data "azurerm_mssql_server" "existing" {
  name                = "sql-contosounversity-sudhirt"
  resource_group_name = "rg-infra-winmig-westus-sudhirt-demopoc"
}

# SQL Database on existing server - Matching existing sql-contosounversity-sudhirt configuration
resource "azurerm_mssql_database" "main" {
  name           = "sqldb-${var.naming_suffix}"
  server_id      = data.azurerm_mssql_server.existing.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  max_size_gb    = 32
  sku_name       = "GP_S_Gen5_1"  # GeneralPurpose Serverless Gen5 1 vCore
  zone_redundant = false
  
  # Serverless configuration
  auto_pause_delay_in_minutes = 60
  min_capacity                = 0.5
  
  tags = var.tags
}

# Note: Firewall rules not needed - existing SQL server has public network access disabled
# App Services will connect via private endpoint or managed identity

output "sql_server_id" { value = data.azurerm_mssql_server.existing.id }
output "sql_server_fqdn" { value = data.azurerm_mssql_server.existing.fully_qualified_domain_name }
output "database_id" { value = azurerm_mssql_database.main.id }
output "database_name" { value = azurerm_mssql_database.main.name }
output "connection_string" { 
  value = "Server=tcp:${data.azurerm_mssql_server.existing.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.main.name};Authentication=Active Directory Default;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive = true
}
