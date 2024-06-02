data "azurerm_resource_group" "group" {
    count = var.resource_group_name == "" ? 0 : 1
    name  = var.resource_group_name
}

data "azurerm_client_config" "current" {
}

data "http" "ip" {
  url = "https://ifconfig.me/ip"
}

resource "azurerm_resource_group" "group" {
    count = var.resource_group_name == "" ? 1 : 0
    name = local.vault_name
    location = var.location
}

resource "azurerm_key_vault" "vault" {
  name                = local.vault_name
  location            = var.location
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
  resource_group_name = var.resource_group_name == "" ? azurerm_resource_group.group[0].name : data.azurerm_resource_group.group[0].name
  
  access_policy {
    tenant_id    = data.azurerm_client_config.current.tenant_id
    object_id    = data.azurerm_client_config.current.object_id

    key_permissions = [
    "Get", 
    "List", 
    "Update", 
    "Create", 
    "Import", 
    "Delete", 
    "Recover", 
    "Backup", 
    "Restore"
  ]

  secret_permissions = [
    "Get",
    "List", 
    "Set", 
    "Delete", 
    "Recover", 
    "Backup", 
    "Restore", 
    "Purge"
  ]

  certificate_permissions = [
    "Get", 
    "List", 
    "Update", 
    "Create", 
    "Import", 
    "Delete",
    "Recover", 
    "Backup", 
    "Restore", 
    "ManageContacts", 
    "ManageIssuers", 
    "GetIssuers", 
    "ListIssuers", 
    "SetIssuers", 
    "DeleteIssuers", 
    "Purge"
  ]
  }

  network_acls {
    bypass = "AzureServices"
    default_action = "Allow"
    
    # ip_rules = local.ip_rules
  }
  
  tags                = var.tags
  lifecycle {
    ignore_changes = [ access_policy ]
  }
}

resource "azurerm_key_vault_secret" "secret" {
  for_each      = local.key_vault_secrets
  
  name         = each.key
  key_vault_id = azurerm_key_vault.vault.id
  value        = each.value
  tags         = var.tags
}
