locals {
    tags = {
        "env": var.environment
    }

    src_root_dir_name = "demo"

    resource_name = "${var.environment}_${local.src_root_dir_name}_app"
    subscription_id_alphanumeric = replace(reverse(split("/", data.azurerm_subscription.current.id))[0], "-", "")
}

data "azurerm_subscription" "current" {
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = local.resource_name
  tags     = local.tags
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.environment}${local.subscription_id_alphanumeric}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
  tags                = local.tags
}