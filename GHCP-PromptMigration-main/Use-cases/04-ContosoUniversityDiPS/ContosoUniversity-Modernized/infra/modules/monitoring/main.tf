# Monitoring Module - Application Insights and Log Analytics
# Application Insights is MANDATORY for all applications

variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "naming_suffix" { type = string }
variable "tags" { 
  type = map(string)
  default = {}
}
variable "retention_days" { 
  type = number
  default = 90
}
variable "daily_data_cap_gb" { 
  type = number
  default = 10
}

resource "azurerm_log_analytics_workspace" "main" {
  name                = "log-${var.naming_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_days
  tags                = merge(var.tags, {
    Purpose    = "Mandatory Application Monitoring"
    Compliance = "Required"
  })
}

resource "azurerm_application_insights" "main" {
  name                = "appi-${var.naming_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.main.id
  application_type    = "web"
  retention_in_days   = var.retention_days
  daily_data_cap_in_gb = var.daily_data_cap_gb
  tags                = merge(var.tags, {
    Purpose    = "Mandatory Application Monitoring"
    Compliance = "Required"
  })
}

# Action Group for Application Insights alerts
resource "azurerm_monitor_action_group" "main" {
  name                = "ag-${var.naming_suffix}"
  resource_group_name = var.resource_group_name
  short_name          = "monitoring"
  tags                = var.tags
}

output "instrumentation_key" { 
  value = azurerm_application_insights.main.instrumentation_key
  sensitive = true
}
output "connection_string" { 
  value = azurerm_application_insights.main.connection_string
  sensitive = true
}
output "app_id" { 
  value = azurerm_application_insights.main.app_id
}
output "workspace_id" { 
  value = azurerm_log_analytics_workspace.main.id
}
