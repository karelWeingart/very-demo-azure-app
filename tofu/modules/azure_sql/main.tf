resource "azurerm_resource_group" "db_group" {
  name     = local.server_name
  location = var.location
  tags = var.tags
}

# resource "azurerm_storage_account" "db_account" {
#    name                     = local.server_name
#    resource_group_name      = azurerm_resource_group.example.name
#    location                 = azurerm_resource_group.example.location
#    account_tier             = "Standard"
#    account_replication_type = "LRS"
# }

resource "azurerm_mssql_server" "db_server" {
  name                         = local.server_name
  resource_group_name          = azurerm_resource_group.db_group.name
  location                     = azurerm_resource_group.db_group.location
  version                      = "12.0"
  administrator_login          = var.admin_login_user
  administrator_login_password = var.admin_login_password
  tags = var.tags
}


resource "azurerm_mssql_database" "db" {
  name           = var.name
  server_id      = azurerm_mssql_server.db_server.id
  max_size_gb    = 1  

  tags = var.tags

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}