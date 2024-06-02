locals {
    subscription_id_alphanumeric = replace(reverse(split("/", data.azurerm_subscription.current.id))[0], "-", "")
}

data "azurerm_subscription" "current" {
}

resource "azurerm_resource_group" "acr_group" {
  location = var.resource_group_location
  name     = var.name
  tags     = var.tags
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.environment}${local.subscription_id_alphanumeric}"
  resource_group_name = azurerm_resource_group.acr_group.name
  location            = azurerm_resource_group.acr_group.location
  sku                 = "Basic"
  admin_enabled       = true
  public_network_access_enabled = true
  tags                = var.tags
}