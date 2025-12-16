# Variables for ContosoUniversity Terraform deployment

variable "environment" {
  description = "Environment name (dev, staging, prod, demopoc)"
  type        = string
  default     = "demopoc"
  
  validation {
    condition     = contains(["dev", "staging", "prod", "demopoc"], var.environment)
    error_message = "Environment must be dev, staging, prod, or demopoc."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "centralindia"  # Central India - confirmed working Asia region with existing SQL servers
}

variable "owner" {
  description = "Owner name for resource naming"
  type        = string
  default     = "sudhirt"
}

variable "service" {
  description = "Service name for resource identification"
  type        = string
  default     = "contosouniv"
}

variable "project" {
  description = "Project name for resource naming"
  type        = string
  default     = "infra"
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "95642268-5116-484d-9b88-7dfce8c20ce4"  # Microsoft Azure Sponsorship-Factory
}

variable "tenant_id" {
  description = "Azure Active Directory Tenant ID"
  type        = string
  default     = "0e478cd4-3e52-496d-ac3a-419ca58ba7ac" # Contoso tenant
}

variable "sql_admin_login" {
  description = "SQL Server administrator login"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "sql_admin_password" {
  description = "SQL Server administrator password"
  type        = string
  sensitive   = true
  
  validation {
    condition     = length(var.sql_admin_password) >= 12
    error_message = "SQL admin password must be at least 12 characters long."
  }
}

variable "entra_admin_object_id" {
  description = "Entra ID (Azure AD) administrator object ID for SQL Server"
  type        = string
}

variable "entra_admin_login" {
  description = "Entra ID (Azure AD) administrator login name"
  type        = string
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for SQL Database and VNet integration for App Services"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

# App Service SKUs
variable "web_app_sku" {
  description = "SKU for Web App Service Plan"
  type        = string
  default     = "B2" # Basic tier with 2 cores, 3.5GB RAM
}

variable "api_app_sku" {
  description = "SKU for API App Service Plan"
  type        = string
  default     = "B2"
}

variable "spa_app_sku" {
  description = "SKU for SPA App Service Plan"
  type        = string
  default     = "B1" # Basic tier with 1 core, 1.75GB RAM
}

# Database SKU
variable "sql_database_sku" {
  description = "SKU for Azure SQL Database"
  type        = string
  default     = "S1" # Standard tier, 20 DTUs
}

variable "sql_database_max_size_gb" {
  description = "Maximum size of the SQL Database in GB"
  type        = number
  default     = 250
}

# Application Insights Configuration (MANDATORY)
variable "app_insights_retention_days" {
  description = "Application Insights data retention in days (MANDATORY for all applications)"
  type        = number
  default     = 90
  
  validation {
    condition     = var.app_insights_retention_days >= 30 && var.app_insights_retention_days <= 730
    error_message = "Application Insights retention must be between 30 and 730 days."
  }
}

variable "app_insights_daily_cap_gb" {
  description = "Application Insights daily data cap in GB (0 = unlimited)"
  type        = number
  default     = 10
}

variable "enforce_app_insights" {
  description = "Enforce Application Insights for all applications (mandatory)"
  type        = bool
  default     = true
}
