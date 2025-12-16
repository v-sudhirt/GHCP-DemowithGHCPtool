# Networking Module - VNet and Subnets

variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "naming_suffix" { type = string }
variable "enable_private_endpoints" { 
  type = bool
  default = false
}
variable "tags" { 
  type = map(string)
  default = {}
}

resource "azurerm_virtual_network" "main" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = "vnet-${var.naming_suffix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "app_service" {
  count                = var.enable_private_endpoints ? 1 : 0
  name                 = "snet-appservice"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = ["10.0.1.0/24"]
  
  delegation {
    name = "app-service-delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "database" {
  count                = var.enable_private_endpoints ? 1 : 0
  name                 = "snet-database"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main[0].name
  address_prefixes     = ["10.0.2.0/24"]
  
  service_endpoints = ["Microsoft.Sql"]
}

output "vnet_id" { value = var.enable_private_endpoints ? azurerm_virtual_network.main[0].id : null }
output "app_service_subnet_id" { value = var.enable_private_endpoints ? azurerm_subnet.app_service[0].id : null }
output "database_subnet_id" { value = var.enable_private_endpoints ? azurerm_subnet.database[0].id : null }
