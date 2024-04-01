output "resource_group_name" {
  value = azurerm_resource_group.db_group.name
}

output "sql_server_name" {
  value = azurerm_mssql_server.db_server.name
}


output "admin_password" {
  sensitive = false
  value     = azurerm_mssql_server.db_server.administrator_login_password
}

output "admin_username" {
  sensitive = false
  value     = azurerm_mssql_server.db_server.administrator_login
}