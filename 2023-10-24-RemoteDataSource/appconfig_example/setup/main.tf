variable "region" {
  type        = string
  default     = "eastus"
  description = "Azure region to deploy resources."
}

variable "naming_prefix" {
  type        = string
  default     = "chorizo"
  description = "Prefix to use for all resources."
}

provider "azurerm" {
  features {

  }
}

resource "azurerm_resource_group" "main" {
  name     = "${var.naming_prefix}-${var.region}"
  location = var.region
}

resource "azurerm_app_configuration" "main" {
  name                = "${var.naming_prefix}-appConf"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "standard"
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "appconf_dataowner" {
  scope                = azurerm_app_configuration.main.id
  role_definition_name = "App Configuration Data Owner"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_app_configuration_key" "shared_vnet" {
  configuration_store_id = azurerm_app_configuration.main.id
  key                    = "shared_vnet"
  label                  = "eastus"
  value                  = "10.0.0.0/16"

  depends_on = [azurerm_role_assignment.appconf_dataowner]
}

resource "azurerm_app_configuration_key" "app_subnet" {
  configuration_store_id = azurerm_app_configuration.main.id
  key                    = "app_subnet"
  label                  = "eastus"
  value                  = "10.0.0.0/24"

  depends_on = [azurerm_role_assignment.appconf_dataowner]
}

output "app_config_store_id" {
  value = azurerm_app_configuration.main.id
}