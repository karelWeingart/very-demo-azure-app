output "azurerm_container_app_url" {
  value = azurerm_container_app.app.latest_revision_fqdn
}

output "azurerm_container_app_revision_name" {
  value = azurerm_container_app.app.latest_revision_name  
}

output "client_ip" {
  value = module.key_vault.client_ip
}

output "key_vault_secrets" {
    value = module.key_vault.key_vault_secrets
    sensitive = true
}